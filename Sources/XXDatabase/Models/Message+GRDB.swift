import GRDB
import XXModels

extension Message: FetchableRecord, MutablePersistableRecord {
  enum Column: String, ColumnExpression {
    case id
    case networkId
    case senderId
    case recipientId
    case groupId
    case date
    case status
    case isUnread
    case text
    case replyMessageId
    case roundURL
    case fileTransferId
  }

  enum Association {
    static let sender = belongsTo(
      Contact.self,
      using: .init([Column.senderId], to: [Contact.Column.id])
    )
  }

  public static let databaseTableName = "messages"

  static func request(_ query: Query) -> QueryInterfaceRequest<Message> {
    var request = Message.all()

    if let id = query.id {
      if id.count == 1, let id = id.first as? Int64 {
        request = request.filter(id: id)
      } else {
        request = request.filter(ids: id.compactMap { $0 })
      }
    }

    switch query.networkId {
    case .some(.some(let networkId)):
      request = request.filter(Column.networkId == networkId)

    case .some(.none):
      request = request.filter(Column.networkId == nil)

    case .none:
      break
    }

    switch query.chat {
    case .group(let groupId):
      request = request.filter(Column.groupId == groupId)

    case .direct(let id1, let id2):
      request = request.filter(
        (Column.senderId == id1 && Column.recipientId == id2) ||
        (Column.senderId == id2 && Column.recipientId == id1)
      )

    case .none:
      break
    }

    if let status = query.status {
      request = request.filter(Set(status.map(\.rawValue)).contains(Column.status))
    }

    if let isUnread = query.isUnread {
      request = request.filter(Column.isUnread == isUnread)
    }

    switch query.fileTransferId {
    case .some(.some(let fileTransferId)):
      request = request.filter(Column.fileTransferId == fileTransferId)

    case .some(.none):
      request = request.filter(Column.fileTransferId == nil)

    case .none:
      break
    }

    if query.isSenderBlocked != nil || query.isSenderBanned != nil {
      let sender = TableAlias(name: "sender")
      request = request.joining(required: Association.sender.aliased(sender))

      if let isSenderBlocked = query.isSenderBlocked {
        request = request.filter(sender[Contact.Column.isBlocked] == isSenderBlocked)
      }

      if let isSenderBanned = query.isSenderBanned {
        request = request.filter(sender[Contact.Column.isBanned] == isSenderBanned)
      }
    }

    switch query.sortBy {
    case .date(desc: false):
      request = request.order(Column.date)

    case .date(desc: true):
      request = request.order(Column.date.desc)
    }

    return request
  }

  static func columnAssignments(_ assignments: Assignments) -> [ColumnAssignment] {
    var columnAssignments: [ColumnAssignment] = []

    if let status = assignments.status {
      columnAssignments.append(Column.status.set(to: status.rawValue))
    }

    if let isUnread = assignments.isUnread {
      columnAssignments.append(Column.isUnread.set(to: isUnread))
    }

    return columnAssignments
  }

  public mutating func didInsert(_ inserted: InsertionSuccess) {
    id = inserted.rowID
  }
}
