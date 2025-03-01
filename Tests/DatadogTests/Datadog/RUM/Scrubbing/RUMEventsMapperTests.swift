/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-Present Datadog, Inc.
 */

import XCTest
@testable import Datadog

class RUMEventsMapperTests: XCTestCase {
    func testGivenMappersEnabled_whenModifyingEvents_itReturnsTheirNewRepresentation() throws {
        let originalViewEvent: RUMViewEvent = .mockRandom()
        let modifiedViewEvent: RUMViewEvent = .mockRandom()

        let originalErrorEvent: RUMErrorEvent = .mockRandom()
        let modifiedErrorEvent: RUMErrorEvent = .mockRandom()

        let originalCrashEvent: RUMCrashEvent = .mockRandom(error: originalErrorEvent)

        let originalResourceEvent: RUMResourceEvent = .mockRandom()
        let modifiedResourceEvent: RUMResourceEvent = .mockRandom()

        let originalActionEvent: RUMActionEvent = .mockRandom()
        let modifiedActionEvent: RUMActionEvent = .mockRandom()

        let originalLongTaskEvent: RUMLongTaskEvent = .mockRandom()
        let modifiedLongTaskEvent: RUMLongTaskEvent = .mockRandom()

        // Given
        let mapper = RUMEventsMapper(
            viewEventMapper: { viewEvent in
                XCTAssertEqual(viewEvent, originalViewEvent, "Mapper should be called with the original event.")
                return modifiedViewEvent
            },
            errorEventMapper: { errorEvent in
                XCTAssertEqual(errorEvent, originalErrorEvent, "Mapper should be called with the original event.")
                return modifiedErrorEvent
            },
            resourceEventMapper: { resourceEvent in
                XCTAssertEqual(resourceEvent, originalResourceEvent, "Mapper should be called with the original event.")
                return modifiedResourceEvent
            },
            actionEventMapper: { actionEvent in
                XCTAssertEqual(actionEvent, originalActionEvent, "Mapper should be called with the original event.")
                return modifiedActionEvent
            },
            longTaskEventMapper: { longTaskEvent in
                XCTAssertEqual(longTaskEvent, originalLongTaskEvent, "Mapper should be called with the original event.")
                return modifiedLongTaskEvent
            }
        )

        // When
        let mappedViewEvent = mapper.map(event: originalViewEvent)
        let mappedErrorEvent = mapper.map(event: originalErrorEvent)
        let mappedCrashEvent = mapper.map(event: originalCrashEvent)
        let mappedResourceEvent = mapper.map(event: originalResourceEvent)
        let mappedActionEvent = mapper.map(event: originalActionEvent)
        let mappedLongTaskEvent = mapper.map(event: originalLongTaskEvent)

        // Then
        XCTAssertEqual(try XCTUnwrap(mappedViewEvent), modifiedViewEvent, "Mapper should return modified event.")
        XCTAssertEqual(try XCTUnwrap(mappedErrorEvent), modifiedErrorEvent, "Mapper should return modified event.")
        XCTAssertEqual(try XCTUnwrap(mappedResourceEvent), modifiedResourceEvent, "Mapper should return modified event.")
        XCTAssertEqual(try XCTUnwrap(mappedActionEvent), modifiedActionEvent, "Mapper should return modified event.")
        XCTAssertEqual(try XCTUnwrap(mappedLongTaskEvent), modifiedLongTaskEvent, "Mapper should return modified event.")

        XCTAssertEqual(try XCTUnwrap(mappedCrashEvent?.model), modifiedErrorEvent, "Mapper should return modified event.")
        AssertDictionariesEqual(
            try XCTUnwrap(mappedCrashEvent?.additionalAttributes),
            originalCrashEvent.additionalAttributes ?? [:],
            "Mapper should return unmodified event attributes."
        )
    }

    func testGivenMappersEnabled_whenDroppingEvents_itReturnsNil() {
        let originalErrorEvent: RUMErrorEvent = .mockRandom()
        let originalCrashEvent: RUMCrashEvent = .mockRandom()
        let originalResourceEvent: RUMResourceEvent = .mockRandom()
        let originalActionEvent: RUMActionEvent = .mockRandom()
        let originalLongTaskEvent: RUMLongTaskEvent = .mockRandom()

        // Given
        let mapper = RUMEventsMapper(
            viewEventMapper: nil,
            errorEventMapper: { errorEvent in
                XCTAssertTrue(errorEvent == originalErrorEvent || errorEvent == originalCrashEvent.model, "Mapper should be called with the original event.")
                return nil
            },
            resourceEventMapper: { resourceEvent in
                XCTAssertEqual(resourceEvent, originalResourceEvent, "Mapper should be called with the original event.")
                return nil
            },
            actionEventMapper: { actionEvent in
                XCTAssertEqual(actionEvent, originalActionEvent, "Mapper should be called with the original event.")
                return nil
            },
            longTaskEventMapper: { longTaskEvent in
                XCTAssertEqual(longTaskEvent, originalLongTaskEvent, "Mapper should be called with the original event.")
                return nil
            }
        )

        // When
        let mappedErrorEvent = mapper.map(event: originalErrorEvent)
        let mappedCrashEvent = mapper.map(event: originalCrashEvent)
        let mappedResourceEvent = mapper.map(event: originalResourceEvent)
        let mappedActionEvent = mapper.map(event: originalActionEvent)
        let mappedLongTaskEvent = mapper.map(event: originalLongTaskEvent)

        // Then
        XCTAssertNil(mappedErrorEvent, "Mapper should return nil.")
        XCTAssertNil(mappedCrashEvent, "Mapper should return nil.")
        XCTAssertNil(mappedResourceEvent, "Mapper should return nil.")
        XCTAssertNil(mappedActionEvent, "Mapper should return nil.")
        XCTAssertNil(mappedLongTaskEvent, "Mapper should return nil.")
    }

    func testGivenMappersDisabled_whenMappingEvents_itReturnsTheirOriginalRepresentation() throws {
        let originalViewEvent: RUMViewEvent = .mockRandom()
        let originalCrashEvent: RUMCrashEvent = .mockRandom()
        let originalErrorEvent: RUMErrorEvent = .mockRandom()
        let originalResourceEvent: RUMResourceEvent = .mockRandom()
        let originalActionEvent: RUMActionEvent = .mockRandom()
        let originalLongTaskEvent: RUMLongTaskEvent = .mockRandom()

        // Given
        let mapper = RUMEventsMapper(
            viewEventMapper: nil,
            errorEventMapper: nil,
            resourceEventMapper: nil,
            actionEventMapper: nil,
            longTaskEventMapper: nil
        )

        // When
        let mappedViewEvent = mapper.map(event: originalViewEvent)
        let mappedErrorEvent = mapper.map(event: originalErrorEvent)
        let mappedCrashEvent = mapper.map(event: originalCrashEvent)
        let mappedResourceEvent = mapper.map(event: originalResourceEvent)
        let mappedActionEvent = mapper.map(event: originalActionEvent)
        let mappedLongTaskEvent = mapper.map(event: originalLongTaskEvent)

        // Then
        XCTAssertEqual(try XCTUnwrap(mappedViewEvent), originalViewEvent, "Mapper should return the original event.")
        XCTAssertEqual(try XCTUnwrap(mappedErrorEvent), originalErrorEvent, "Mapper should return the original event.")
        XCTAssertEqual(try XCTUnwrap(mappedCrashEvent), originalCrashEvent, "Mapper should return the original event.")
        XCTAssertEqual(try XCTUnwrap(mappedResourceEvent), originalResourceEvent, "Mapper should return the original event.")
        XCTAssertEqual(try XCTUnwrap(mappedActionEvent), originalActionEvent, "Mapper should return the original event.")
        XCTAssertEqual(try XCTUnwrap(mappedLongTaskEvent), originalLongTaskEvent, "Mapper should return the original event.")
    }

    func testGivenUnrecognizedEvent_whenMapping_itReturnsItsOriginalImplementation() throws {
        // Given
        struct UnrecognizedEvent: Encodable {
            let value: String
        }

        let originalEvent = UnrecognizedEvent(value: .mockRandom())

        // When
        let mapper = RUMEventsMapper(
            viewEventMapper: nil,
            errorEventMapper: { _ in nil },
            resourceEventMapper: { _ in nil },
            actionEventMapper: { _ in nil },
            longTaskEventMapper: { _ in nil }
        )

        let mappedEvent = try XCTUnwrap(mapper.map(event: originalEvent))

        // Then
        XCTAssertEqual(mappedEvent.value, originalEvent.value)
    }
}
