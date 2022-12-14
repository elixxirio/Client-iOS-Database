import Foundation

/// Represents group
public struct Group: Identifiable, Equatable, Hashable, Codable {
  /// Unique identifier of a group
  public typealias ID = Data

  /// Represents group authorization status
  public enum AuthStatus: String, Equatable, Hashable, Codable {
    /// Invitation to the group received
    case pending

    /// Leaving the group
    case deleting

    /// Participating the group
    case participating

    /// Group invitation was hidden
    case hidden
  }

  /// Instantiate group representation
  /// 
  /// - Parameters:
  ///   - id: Unique identifier of the group
  ///   - name: Group name
  ///   - leaderId: Group leader's contact ID
  ///   - createdAt: Group creation date
  ///   - authStatus: Group authorization status
  ///   - serialized: Serialized data
  public init(
    id: ID,
    name: String,
    leaderId: Contact.ID,
    createdAt: Date,
    authStatus: AuthStatus,
    serialized: Data
  ) {
    self.id = id
    self.name = name
    self.leaderId = leaderId
    self.createdAt = createdAt
    self.authStatus = authStatus
    self.serialized = serialized
  }

  /// Unique identifier of the group
  public var id: ID

  /// Group name
  public var name: String

  /// Group leader's contact ID
  public var leaderId: Contact.ID

  /// Group creation date
  public var createdAt: Date

  /// Group authorization status
  public var authStatus: AuthStatus

  /// Serialized data
  public var serialized: Data
}

extension Group {
  /// Fetch groups operation
  public typealias Fetch = XXModels.Fetch<Group, Query>

  /// Fetch groups operation publisher
  public typealias FetchPublisher = XXModels.FetchPublisher<Group, Query>

  /// Save (insert new or update existing) group operation
  public typealias Save = XXModels.Save<Group>

  /// Delete group operation
  public typealias Delete = XXModels.Delete<Group>

  /// Query used for fetching groups
  public struct Query: Equatable {
    /// Groups sort order
    public enum SortOrder: Equatable {
      /// Sort by creation date
      ///
      /// - Parameters:
      ///   - desc: Sort in descending order (defaults to `false`)
      case createdAt(desc: Bool = false)
    }

    /// Instantiate query
    ///
    /// - Parameters:
    ///   - id: Filter by id (defaults to `nil`).
    ///   - withMessages: Filter groups by messages.
    ///     If `true`, only groups that have at least one message will be fetched.
    ///     If `false`, only groups that don't have a message will be fetched.
    ///     If `nil` (default), the filter is not used.
    ///   - authStatus: Filter groups by auth status.
    ///     If set, only groups with any of the provided auth statuses will be fetched.
    ///     If `nil` (default), the filter is not used.
    ///   - isLeaderBlocked: Filter by leader contact's `isBlocked` status.
    ///     If `true`, only groups with blocked leader contacts are included.
    ///     If `false`, only groups with non-blocked contacts are included.
    ///     If `nil` (default), the filter is not used.
    ///   - isLeaderBanned: Filter by leader contact's `isBlocked` status.
    ///     If `true`, only groups with blocked leader contacts are included.
    ///     If `false`, only groups with non-blocked contacts are included.
    ///     If `nil` (default), the filter is not used.
    ///   - sortBy: Sort order (defaults to `.createdAt(desc: true)`).
    public init(
      id: Set<Group.ID>? = nil,
      withMessages: Bool? = nil,
      authStatus: Set<AuthStatus>? = nil,
      isLeaderBlocked: Bool? = nil,
      isLeaderBanned: Bool? = nil,
      sortBy: SortOrder = .createdAt(desc: true)
    ) {
      self.id = id
      self.withMessages = withMessages
      self.authStatus = authStatus
      self.isLeaderBlocked = isLeaderBlocked
      self.isLeaderBanned = isLeaderBanned
      self.sortBy = sortBy
    }

    /// Filter by id
    public var id: Set<Group.ID>?

    /// Filter groups by messages
    ///
    /// If `true`, only groups that have at least one message will be fetched.
    /// If `false`, only groups that don't have a message will be fetched.
    /// If `nil`, the filter is not used
    public var withMessages: Bool?

    /// Filter groups by auth status
    ///
    /// If set, only groups with any of the provided auth statuses will be fetched.
    /// If `nil`, the filter is not used.
    public var authStatus: Set<AuthStatus>?

    /// Filter by leader contact's `isBlocked` status
    ///
    /// If `true`, only groups with blocked leader contacts are included.
    /// If `false`, only groups with non-blocked contacts are included.
    /// If `nil`, the filter is not used.
    public var isLeaderBlocked: Bool?

    /// Filter by leader contact's `isBanned` status
    ///
    /// If `true`, only groups with banned leader contacts are included.
    /// If `false`, only groups with non-banned leader contacts are included.
    /// If `nil`, the filter is not used.
    public var isLeaderBanned: Bool?

    /// Groups sort order
    public var sortBy: SortOrder
  }
}
