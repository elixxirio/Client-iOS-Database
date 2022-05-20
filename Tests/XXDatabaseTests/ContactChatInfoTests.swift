import CustomDump
import XCTest
import XXModels
@testable import XXDatabase

final class ContactChatInfoTests: XCTestCase {
  var db: Database!

  override func setUp() async throws {
    db = try Database.inMemory()
  }

  override func tearDown() async throws {
    db = nil
  }

  func testFetching() throws {
    let fetch: ContactChatInfo.Fetch = db.fetch(ContactChatInfo.request(_:))
    var results = [ContactChatInfo]()

    // Mock up contacts:

    let contactA = try db.insert(Contact.stub("A"))
    let contactB = try db.insert(Contact.stub("B"))
    let contactC = try db.insert(Contact.stub("C"))

    // Mock up conversation between contact A and B:

    _ = try db.insert(Message.stub(
      from: contactA,
      to: contactB,
      at: 1
    ))

    _ = try db.insert(Message.stub(
      from: contactB,
      to: contactA,
      at: 2
    ))

    let lastMessage_betweenAandB_at3 = try db.insert(Message.stub(
      from: contactA,
      to: contactB,
      at: 3
    ))

    // Mock up conversation between contact A and C:

    _ = try db.insert(Message.stub(
      from: contactA,
      to: contactC,
      at: 4
    ))

    let lastMessage_betweenAandC_at5 = try db.insert(Message.stub(
      from: contactC,
      to: contactA,
      at: 5
    ))

    // Mock up conversation between contact B and C:

    _ = try db.insert(Message.stub(
      from: contactB,
      to: contactC,
      at: 6
    ))

    let lastMessage_betweenBandC_at7 = try db.insert(Message.stub(
      from: contactC,
      to: contactB,
      at: 7
    ))

    // Fetch contact chat infos for user A:

    results = try fetch(ContactChatInfo.Query(userId: contactA.id))

    XCTAssertNoDifference(results, [
      ContactChatInfo(contact: contactC, lastMessage: lastMessage_betweenAandC_at5),
      ContactChatInfo(contact: contactB, lastMessage: lastMessage_betweenAandB_at3),
    ])
    XCTAssertEqual(results.count, 2)
    XCTAssertNoDifference(results.get(0)?.contact, contactC)
    XCTAssertNoDifference(results.get(0)?.lastMessage, lastMessage_betweenAandC_at5)
    XCTAssertNoDifference(results.get(1)?.contact, contactB)
    XCTAssertNoDifference(results.get(1)?.lastMessage, lastMessage_betweenAandB_at3)

    // Fetch contact chat infos for user B:

    results = try fetch(ContactChatInfo.Query(userId: contactB.id))

    XCTAssertNoDifference(results, [
      ContactChatInfo(contact: contactC, lastMessage: lastMessage_betweenBandC_at7),
      ContactChatInfo(contact: contactA, lastMessage: lastMessage_betweenAandB_at3),
    ])
    XCTAssertEqual(results.count, 2)
    XCTAssertNoDifference(results.get(0)?.contact, contactC)
    XCTAssertNoDifference(results.get(0)?.lastMessage, lastMessage_betweenBandC_at7)
    XCTAssertNoDifference(results.get(1)?.contact, contactA)
    XCTAssertNoDifference(results.get(1)?.lastMessage, lastMessage_betweenAandB_at3)

    // Fetch contact chat infos for user C:

    results = try fetch(ContactChatInfo.Query(userId: contactC.id))

    XCTAssertNoDifference(results, [
      ContactChatInfo(contact: contactB, lastMessage: lastMessage_betweenBandC_at7),
      ContactChatInfo(contact: contactA, lastMessage: lastMessage_betweenAandC_at5),
    ])
    XCTAssertEqual(results.count, 2)
    XCTAssertNoDifference(results.get(0)?.contact, contactB)
    XCTAssertNoDifference(results.get(0)?.lastMessage, lastMessage_betweenBandC_at7)
    XCTAssertNoDifference(results.get(1)?.contact, contactA)
    XCTAssertNoDifference(results.get(1)?.lastMessage, lastMessage_betweenAandC_at5)
  }
}

private extension Array {
  func get(_ index: Index) -> Element? {
    guard indices.contains(index) else { return nil }
    return self[index]
  }
}
