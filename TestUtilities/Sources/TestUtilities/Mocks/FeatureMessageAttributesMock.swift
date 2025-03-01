/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-Present Datadog, Inc.
 */

import Foundation

@testable import Datadog

extension FeatureBaggage: AnyMockable, RandomMockable {
    static func mockAny() -> Self {
        .init([String: String].mockAny())
    }

    static func mockRandom() -> Self {
        .init([String: String].mockRandom())
    }
}
