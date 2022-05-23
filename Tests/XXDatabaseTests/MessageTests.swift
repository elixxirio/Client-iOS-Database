import CustomDump
import XCTest
import XXModels
@testable import XXDatabase

final class MessageTests: XCTestCase {
  var db: Database!

  override func setUp() async throws {
    db = try Database.inMemory()
  }

  override func tearDown() async throws {
    db = nil
  }

  func testFetchingDirectMessages() throws {
    let fetch: Message.Fetch = db.fetch(Message.request(_:))
    let save: Message.Save = db.save(_:)

    let contactA = Contact.stub("A")
    let contactB = Contact.stub("B")
    let contactC = Contact.stub("C")

    _ = try db.insert(contactA)
    _ = try db.insert(contactB)
    _ = try db.insert(contactC)

    // Save conversation between contacts A and B:

    let message1 = try save(.stub(
      from: contactA,
      to: contactB,
      at: 1
    ))

    let message2 = try save(.stub(
      from: contactB,
      to: contactA,
      at: 2
    ))

    let message3 = try save(.stub(
      from: contactA,
      to: contactB,
      at: 3
    ))

    // Save other messages:

    _ = try save(.stub(
      from: contactA,
      to: contactC,
      at: 1
    ))

    _ = try save(.stub(
      from: contactC,
      to: contactA,
      at: 1
    ))

    _ = try save(.stub(
      from: contactB,
      to: contactC,
      at: 1
    ))

    _ = try save(.stub(
      from: contactC,
      to: contactB,
      at: 1
    ))

    // Fetch conversation between contacts A and B:

    XCTAssertNoDifference(
      try fetch(Message.Query(chat: .direct(contactA.id, contactB.id), sortBy: .date())),
      [
        message1,
        message2,
        message3,
      ]
    )
  }

  func testFetchingGroupMessages() throws {
    let fetch: Message.Fetch = db.fetch(Message.request(_:))
    let save: Message.Save = db.save(_:)

    let contactA = Contact.stub("A")
    let contactB = Contact.stub("B")
    let contactC = Contact.stub("C")

    _ = try db.insert(contactA)
    _ = try db.insert(contactB)
    _ = try db.insert(contactC)

    let groupA = Group.stub("A", leaderId: contactA.id, createdAt: .stub(1))
    let groupB = Group.stub("B", leaderId: contactB.id, createdAt: .stub(2))

    _ = try db.save(groupA)
    _ = try db.save(groupB)

    // Save group A messages:

    let message1 = try save(.stub(
      from: contactA,
      to: groupA,
      at: 1
    ))

    let message2 = try save(.stub(
      from: contactB,
      to: groupA,
      at: 2
    ))

    let message3 = try save(.stub(
      from: contactC,
      to: groupA,
      at: 3
    ))

    // Save other messages:

    _ = try save(.stub(
      from: contactA,
      to: contactC,
      at: 1
    ))

    _ = try save(.stub(
      from: contactC,
      to: contactA,
      at: 1
    ))

    _ = try save(.stub(
      from: contactB,
      to: contactC,
      at: 1
    ))

    _ = try save(.stub(
      from: contactC,
      to: contactB,
      at: 1
    ))

    _ = try save(.stub(
      from: contactA,
      to: groupB,
      at: 1
    ))

    _ = try save(.stub(
      from: contactB,
      to: groupB,
      at: 1
    ))

    _ = try save(.stub(
      from: contactC,
      to: groupB,
      at: 1
    ))

    // Fetch messages in group A:

    XCTAssertNoDifference(
      try fetch(Message.Query(chat: .group(groupA.id), sortBy: .date(desc: true))),
      [
        message3,
        message2,
        message1,
      ]
    )
  }
}
