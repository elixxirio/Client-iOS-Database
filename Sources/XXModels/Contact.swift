import Combine
import Foundation

public struct Contact: Identifiable, Equatable, Codable {
  public init(
    id: Data,
    marshaled: Data? = nil,
    username: String? = nil,
    email: String? = nil,
    phone: String? = nil,
    nickname: String? = nil
  ) {
    self.id = id
    self.marshaled = marshaled
    self.username = username
    self.email = email
    self.phone = phone
    self.nickname = nickname
  }

  public var id: Data
  public var marshaled: Data?
  public var username: String?
  public var email: String?
  public var phone: String?
  public var nickname: String?
}

extension Contact {
  public typealias Fetch = (Query, Order) throws -> [Contact]
  public typealias FetchPublisher = (Query, Order) -> AnyPublisher<[Contact], Error>
  public typealias Insert = (Contact) throws -> Contact
  public typealias InsertPublisher = (Contact) -> AnyPublisher<Contact, Error>
  public typealias Update = (Contact) throws -> Contact
  public typealias UpdatePublisher = (Contact) -> AnyPublisher<Contact, Error>
  public typealias Delete = (Contact) throws -> Bool
  public typealias DeletePublisher = (Contact) -> AnyPublisher<Bool, Error>

  public struct Query: Equatable {
    public static let all = Query()

    public init() {}
  }

  public enum Order: Equatable {
    case username(desc: Bool = false)
  }
}
