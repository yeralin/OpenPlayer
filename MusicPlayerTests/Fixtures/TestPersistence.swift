//
//  TestPersistence.swift
//  MusicPlayerTests
//
//  Points the app's persistence singletons at throwaway storage for a test.
//

import CoreData
import UIKit
@testable import MusicPlayer

/// Redirects the shared persistence managers to a temporary Documents folder
/// and an in-memory Core Data store, and restores them in `tearDown()`.
///
/// The managers are singletons used all over the app, so rather than
/// threading new instances through every caller, a test swaps the state of
/// the shared instances (`docsUrl` and `managedObjectContext`). Production code
/// keeps working unchanged and never touches the real Documents folder or
/// SQLite store during tests.
final class TestPersistence {

    let documentsUrl: URL
    let context: NSManagedObjectContext

    private let container: NSPersistentContainer
    private var originals: [(manager: PersistenceController, docsUrl: URL, context: NSManagedObjectContext?)] = []

    private static var managers: [PersistenceController] {
        [PlaylistPersistencyManager.sharedInstance, SongPersistencyManager.sharedInstance]
    }

    init() throws {
        documentsUrl = FileManager.default.temporaryDirectory
            .appendingPathComponent("OpenPlayerTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: documentsUrl, withIntermediateDirectories: true)

        // Reuse the app's model object. Loading MusicPlayer.momd a second time
        // would register two entity descriptions for the same classes, which
        // makes `SongEntity(context:)` ambiguous.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            throw "Tests must run hosted in the MusicPlayer app"
        }
        let model = appDelegate.persistentContainer.managedObjectModel
        container = NSPersistentContainer(name: "MusicPlayerTests", managedObjectModel: model)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        container.persistentStoreDescriptions = [description]
        var loadError: Error?
        container.loadPersistentStores { _, error in loadError = error }
        if let loadError = loadError {
            throw loadError
        }
        context = container.viewContext

        for manager in Self.managers {
            originals.append((manager, manager.docsUrl, manager.managedObjectContext))
            manager.docsUrl = documentsUrl
            manager.managedObjectContext = context
        }
    }

    func tearDown() {
        for original in originals {
            original.manager.docsUrl = original.docsUrl
            original.manager.managedObjectContext = original.context
        }
        originals.removeAll()
        try? FileManager.default.removeItem(at: documentsUrl)
    }

    // MARK: Builders

    /// The silent mp3 bundled with the app for tests.
    static var testSongUrl: URL {
        guard let url = Bundle.main.url(forResource: "test - test", withExtension: "mp3") else {
            fatalError("The app bundle is missing 'test - test.mp3'")
        }
        return url
    }

    /// Creates a playlist and puts a copy of the test mp3 in its folder for
    /// each file name. Call `populateSongs` to turn the files into songs.
    @discardableResult
    func makePlaylist(_ name: String, songFiles: [String] = []) throws -> PlaylistEntity {
        let playlist = try PlaylistPersistencyManager.sharedInstance.createPlaylist(name: name)
        let folder = documentsUrl.appendingPathComponent(name, isDirectory: true)
        for fileName in songFiles {
            try FileManager.default.copyItem(at: Self.testSongUrl,
                                             to: folder.appendingPathComponent(fileName))
        }
        return playlist
    }

    /// Creates a playlist with songs and returns them in playlist order.
    func makeSongs(_ songFiles: [String], inPlaylist name: String = "Test") throws -> [SongEntity] {
        let playlist = try makePlaylist(name, songFiles: songFiles)
        return try SongPersistencyManager.sharedInstance.populateSongs(forPlaylist: playlist)
    }

    /// A search-result style song: remote URL, no playlist, not saved.
    func makeRemoteSong(_ title: String = "Artist - Title",
                        url: URL = URL(string: "http://127.0.0.1:9/song.mp3")!) -> SongEntity {
        let song = SongEntity(context: context)
        song.songName = title
        song.songUrl = url
        song.songArtist = "Artist"
        song.songTitle = "Title"
        return song
    }

    func fetchCount(_ entityName: String) throws -> Int {
        try context.count(for: NSFetchRequest<NSFetchRequestResult>(entityName: entityName))
    }
}
