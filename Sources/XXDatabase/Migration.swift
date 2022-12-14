import GRDB

struct Migration {
  var id: String
  var migrate: (GRDB.Database) throws -> Void
}

extension Sequence where Element == Migration {
  static var all: [Migration] {[
    Migration(id: "0") { db in
      try db.create(table: "contacts") { t in
        t.column("id", .blob).notNull().primaryKey()
        t.column("marshaled", .blob)
        t.column("username", .text)
        t.column("email", .text)
        t.column("phone", .text)
        t.column("nickname", .text)
        t.column("photo", .blob)
        t.column("authStatus", .text).notNull()
        t.column("isRecent", .boolean).notNull()
        t.column("createdAt", .datetime).notNull()
      }

      try db.create(table: "groups") { t in
        t.column("id", .blob).notNull().primaryKey()
        t.column("name", .text).notNull()
        t.column("leaderId", .blob).notNull()
          .references("contacts", column: "id", onDelete: .cascade, onUpdate: .cascade)
        t.column("createdAt", .datetime).notNull()
        t.column("authStatus", .text).notNull()
        t.column("serialized", .blob).notNull()
      }

      try db.create(table: "groupMembers") { t in
        t.column("groupId").notNull()
          .references("groups", column: "id", onDelete: .cascade, onUpdate: .cascade)
        t.column("contactId").notNull()
          .references("contacts", column: "id", onDelete: .cascade, onUpdate: .cascade)
        t.primaryKey(["groupId", "contactId"])
      }

      try db.create(table: "fileTransfers") { t in
        t.column("id", .blob).notNull().primaryKey()
        t.column("contactId", .blob).notNull()
          .references("contacts", column: "id", onDelete: .cascade, onUpdate: .cascade)
        t.column("name", .text).notNull()
        t.column("type", .text).notNull()
        t.column("data", .blob)
        t.column("progress", .double).notNull()
        t.column("isIncoming", .boolean).notNull()
        t.column("createdAt", .datetime).notNull()
      }

      try db.create(table: "messages") { t in
        t.column("id", .integer).notNull().primaryKey(autoincrement: true)
        t.column("networkId", .blob)
        t.column("senderId", .blob).notNull()
          .references("contacts", column: "id", onDelete: .cascade, onUpdate: .cascade)
        t.column("recipientId", .blob)
          .references("contacts", column: "id", onDelete: .cascade, onUpdate: .cascade)
        t.column("groupId", .blob)
          .references("groups", column: "id", onDelete: .cascade, onUpdate: .cascade)
        t.column("date", .datetime).notNull()
        t.column("status", .text).notNull()
        t.column("isUnread", .boolean).notNull()
        t.column("text", .text).notNull()
        t.column("replyMessageId", .blob)
        t.column("roundURL", .text)
        t.column("fileTransferId", .blob)
          .references("fileTransfers", column: "id", onDelete: .cascade, onUpdate: .cascade)
      }
    },
    Migration(id: "1") { db in
      try db.alter(table: "contacts") { t in
        t.add(column: "isBlocked", .boolean).defaults(to: false)
        t.add(column: "isBanned", .boolean).defaults(to: false)
      }
    },
  ]}
}
