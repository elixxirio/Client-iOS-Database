import GRDB
import XXModels

extension GroupInfo: FetchableRecord {
  enum Column: String, ColumnExpression {
    case group
    case leader
    case members
  }

  static func request(_ query: Query) -> QueryInterfaceRequest<GroupInfo> {
    var request = Group
      .including(required: Group.Association.leader.forKey(Column.leader.rawValue))
      .including(all: Group.Association.members.forKey(Column.members.rawValue))
      .asRequest(of: GroupInfo.self)

    if let groupId = query.groupId {
      request = request.filter(Group.Column.id == groupId)
    }

    switch query.sortBy {
    case .groupName(desc: false):
      request = request.order(Group.Column.name)

    case .groupName(desc: true):
      request = request.order(Group.Column.name.desc)
    }

    return request
  }
}
