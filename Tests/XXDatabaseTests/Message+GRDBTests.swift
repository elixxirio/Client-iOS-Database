import CustomDump
import XCTest
import XXModels
@testable import XXDatabase

final class MessageGRDBTests: XCTestCase {
  var db: Database!

  override func setUp() async throws {
    db = try Database.inMemory()
  }

  override func tearDown() async throws {
    db = nil
  }

  func testFetchingDirectMessages() throws {
    // Mock up contacts:

    let contactA = try db.saveContact(.stub("A"))
    let contactB = try db.saveContact(.stub("B"))
    let contactC = try db.saveContact(.stub("C"))

    // Save conversation between contacts A and B:

    let message1 = try db.saveMessage(.stub(
      from: contactA,
      to: contactB,
      at: 1
    ))

    let message2 = try db.saveMessage(.stub(
      from: contactB,
      to: contactA,
      at: 2
    ))

    let message3 = try db.saveMessage(.stub(
      from: contactA,
      to: contactB,
      at: 3
    ))

    // Save other messages:

    try db.saveMessage(.stub(
      from: contactA,
      to: contactC,
      at: 1
    ))

    try db.saveMessage(.stub(
      from: contactC,
      to: contactA,
      at: 1
    ))

    try db.saveMessage(.stub(
      from: contactB,
      to: contactC,
      at: 1
    ))

    try db.saveMessage(.stub(
      from: contactC,
      to: contactB,
      at: 1
    ))

    // Fetch conversation between contacts A and B:

    XCTAssertNoDifference(
      try db.fetchMessages(Message.Query(chat: .direct(contactA.id, contactB.id), sortBy: .date())),
      [
        message1,
        message2,
        message3,
      ]
    )
  }

  func testFetchingGroupMessages() throws {
    // Mock up contacts and groups:

    let contactA = try db.saveContact(.stub("A"))
    let contactB = try db.saveContact(.stub("B"))
    let contactC = try db.saveContact(.stub("C"))
    let groupA = try db.saveGroup(.stub("A", leaderId: contactA.id, createdAt: .stub(1)))
    let groupB = try db.saveGroup(.stub("B", leaderId: contactB.id, createdAt: .stub(2)))

    // Save group A messages:

    let message1 = try db.saveMessage(.stub(
      from: contactA,
      to: groupA,
      at: 1
    ))

    let message2 = try db.saveMessage(.stub(
      from: contactB,
      to: groupA,
      at: 2
    ))

    let message3 = try db.saveMessage(.stub(
      from: contactC,
      to: groupA,
      at: 3
    ))

    // Save other messages:

    try db.saveMessage(.stub(
      from: contactA,
      to: contactC,
      at: 1
    ))

    try db.saveMessage(.stub(
      from: contactC,
      to: contactA,
      at: 1
    ))

    try db.saveMessage(.stub(
      from: contactB,
      to: contactC,
      at: 1
    ))

    try db.saveMessage(.stub(
      from: contactC,
      to: contactB,
      at: 1
    ))

    try db.saveMessage(.stub(
      from: contactA,
      to: groupB,
      at: 1
    ))

    try db.saveMessage(.stub(
      from: contactB,
      to: groupB,
      at: 1
    ))

    try db.saveMessage(.stub(
      from: contactC,
      to: groupB,
      at: 1
    ))

    // Fetch messages in group A:

    XCTAssertNoDifference(
      try db.fetchMessages(Message.Query(chat: .group(groupA.id), sortBy: .date(desc: true))),
      [
        message3,
        message2,
        message1,
      ]
    )
  }

  func testFetchingById() throws {
    // Mock up contacts

    let contactA = try db.saveContact(.stub("A"))
    let contactB = try db.saveContact(.stub("B"))
    let contactC = try db.saveContact(.stub("C"))

    // Mock up messages:

    let message1 = try db.saveMessage(.stub(
      from: contactA,
      to: contactB,
      at: 1
    ))

    let message2 = try db.saveMessage(.stub(
      from: contactB,
      to: contactA,
      at: 2
    ))

    let message3 = try db.saveMessage(.stub(
      from: contactA,
      to: contactC,
      at: 3
    ))

    // Fetch messages by id:

    XCTAssertNoDifference(
      try db.fetchMessages(.init(id: message1.id, sortBy: .date())),
      [message1]
    )

    XCTAssertNoDifference(
      try db.fetchMessages(.init(id: message2.id, sortBy: .date())),
      [message2]
    )

    XCTAssertNoDifference(
      try db.fetchMessages(.init(id: message3.id, sortBy: .date())),
      [message3]
    )
  }

  func testFetchingByNetworkId() throws {
    // Mock up contacts

    let contactA = try db.saveContact(.stub("A"))
    let contactB = try db.saveContact(.stub("B"))
    let contactC = try db.saveContact(.stub("C"))

    // Mock up messages:

    let message1 = try db.saveMessage(.stub(
      from: contactA,
      to: contactB,
      at: 1,
      networkId: "1".data(using: .utf8)!
    ))

    let message2 = try db.saveMessage(.stub(
      from: contactB,
      to: contactA,
      at: 2,
      networkId: "2".data(using: .utf8)!
    ))

    let message3 = try db.saveMessage(.stub(
      from: contactA,
      to: contactC,
      at: 3,
      networkId: nil
    ))

    // Fetch messages by network id:

    XCTAssertNoDifference(
      try db.fetchMessages(.init(networkId: "1".data(using: .utf8)!, sortBy: .date())),
      [message1]
    )

    XCTAssertNoDifference(
      try db.fetchMessages(.init(networkId: "2".data(using: .utf8)!, sortBy: .date())),
      [message2]
    )

    XCTAssertNoDifference(
      try db.fetchMessages(.init(networkId: .some(nil), sortBy: .date())),
      [message3]
    )

    XCTAssertNoDifference(
      try db.fetchMessages(.init(networkId: .none, sortBy: .date())),
      [message1, message2, message3]
    )
  }

  func testFetchingByUnreadStatus() throws {
    // Mock up contacts

    let contactA = try db.saveContact(.stub("A"))
    let contactB = try db.saveContact(.stub("B"))

    // Mock up messages:

    let message1 = try db.saveMessage(.stub(
      from: contactA,
      to: contactB,
      at: 1,
      isUnread: true
    ))

    let message2 = try db.saveMessage(.stub(
      from: contactB,
      to: contactA,
      at: 2,
      isUnread: false
    ))

    // Fetch messages by unread status:

    XCTAssertNoDifference(
      try db.fetchMessages(.init(isUnread: true, sortBy: .date())),
      [message1]
    )

    XCTAssertNoDifference(
      try db.fetchMessages(.init(isUnread: false, sortBy: .date())),
      [message2]
    )

    XCTAssertNoDifference(
      try db.fetchMessages(.init(isUnread: nil, sortBy: .date())),
      [message1, message2]
    )
  }

  func testDeletingMany() throws {
    // Mock up contacts

    let contactA = try db.saveContact(.stub("A"))
    let contactB = try db.saveContact(.stub("B"))
    let contactC = try db.saveContact(.stub("C"))

    // Mock up messages:

    try db.saveMessage(.stub(
      from: contactA,
      to: contactB,
      at: 1
    ))

    try db.saveMessage(.stub(
      from: contactB,
      to: contactA,
      at: 2
    ))

    try db.saveMessage(.stub(
      from: contactA,
      to: contactB,
      at: 3
    ))

    let message4_ac = try db.saveMessage(.stub(
      from: contactA,
      to: contactC,
      at: 4
    ))

    let message5_ca = try db.saveMessage(.stub(
      from: contactC,
      to: contactA,
      at: 5
    ))

    let message6_bc = try db.saveMessage(.stub(
      from: contactB,
      to: contactC,
      at: 6
    ))

    let message7_cb = try db.saveMessage(.stub(
      from: contactC,
      to: contactB,
      at: 7
    ))

    // Delete messages between contact A and B:

    XCTAssertEqual(
      try db.deleteMessages(.init(chat: .direct(contactA.id, contactB.id))),
      3
    )

    XCTAssertNoDifference(
      try db.fetchMessages(.init(sortBy: .date())),
      [
        message4_ac,
        message5_ca,
        message6_bc,
        message7_cb,
      ]
    )
  }
}
