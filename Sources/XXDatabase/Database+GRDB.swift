import Foundation
import GRDB
import XXModels

extension XXModels.Database {
  /// Create in-memory database implementation powered by GRDB
  ///
  /// - Returns: Database implementation.
  /// - Throws: Error when database can't be instantiated.
  public static func inMemory() throws -> XXModels.Database {
    try grdb(writer: DatabaseQueue())
  }

  /// Create on-disk database implementation powered by GRDB
  ///
  /// - Parameters:
  ///   - path: Path to the database file.
  /// - Returns: Database implementation.
  /// - Throws: Error when database can't be instantiated.
  public static func onDisk(path: String) throws -> XXModels.Database {
    try grdb(writer: try DatabaseQueue(path: path))
  }

  static func grdb(
    writer: DatabaseWriter,
    queue: DispatchQueue = DispatchQueue(label: "XXDatabase"),
    migrations: [Migration] = .all
  ) throws -> XXModels.Database {
    var migrator = DatabaseMigrator()
    migrations.forEach { migration in
      migrator.registerMigration(migration.id, migrate: migration.migrate)
    }
    try migrator.migrate(writer)
    return XXModels.Database(
      fetchChatInfos: .grdb(writer, queue),
      fetchChatInfosPublisher: .grdb(writer, queue),
      fetchContacts: .grdb(writer, queue, Contact.request(_:)),
      fetchContactsPublisher: .grdb(writer, queue, Contact.request(_:)),
      saveContact: .grdb(writer, queue),
      bulkUpdateContacts: .grdb(writer, queue, Contact.request(_:), Contact.columnAssignments(_:)),
      deleteContact: .grdb(writer, queue),
      fetchContactChatInfos: .grdb(writer, queue, ContactChatInfo.request(_:)),
      fetchContactChatInfosPublisher: .grdb(writer, queue, ContactChatInfo.request(_:)),
      fetchGroups: .grdb(writer, queue, Group.request(_:)),
      fetchGroupsPublisher: .grdb(writer, queue, Group.request(_:)),
      saveGroup: .grdb(writer, queue),
      deleteGroup: .grdb(writer, queue),
      fetchGroupChatInfos: .grdb(writer, queue, GroupChatInfo.request(_:)),
      fetchGroupChatInfosPublisher: .grdb(writer, queue, GroupChatInfo.request(_:)),
      fetchGroupInfos: .grdb(writer, queue, GroupInfo.request(_:)),
      fetchGroupInfosPublisher: .grdb(writer, queue, GroupInfo.request(_:)),
      saveGroupMember: .grdb(writer, queue),
      deleteGroupMember: .grdb(writer, queue),
      fetchMessages: .grdb(writer, queue, Message.request(_:)),
      fetchMessagesPublisher: .grdb(writer, queue, Message.request(_:)),
      saveMessage: .grdb(writer, queue),
      bulkUpdateMessages: .grdb(writer, queue, Message.request(_:), Message.columnAssignments(_:)),
      deleteMessage: .grdb(writer, queue),
      deleteMessages: .grdb(writer, queue, Message.request(_:)),
      fetchFileTransfers: .grdb(writer, queue, FileTransfer.request(_:)),
      fetchFileTransfersPublisher: .grdb(writer, queue, FileTransfer.request(_:)),
      saveFileTransfer: .grdb(writer, queue),
      deleteFileTransfer: .grdb(writer, queue),
      drop: .grdb(writer, queue)
    )
  }
}
