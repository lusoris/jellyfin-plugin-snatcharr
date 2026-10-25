// SPDX-FileCopyrightText: 2026 lusoris <lusoris@pm.me>
// SPDX-License-Identifier: GPL-3.0-or-later

#if SEMGREP_FIXTURE

using System;

namespace TestData;

public class TestDateTimeNow
{
    public void Run(TimeProvider timeProvider)
    {
        // ruleid: no-datetime-now
        var t1 = DateTime.Now;

        // ruleid: no-datetime-now
        var t2 = DateTime.UtcNow;

        // ruleid: no-datetime-now
        var t3 = DateTimeOffset.Now;

        // ruleid: no-datetime-now
        var t4 = DateTimeOffset.UtcNow;

        // ruleid: no-datetime-now
        var t5 = System.DateTime.Now;

        // ruleid: no-datetime-now
        var t6 = System.DateTime.UtcNow;

        // ruleid: no-datetime-now
        var t7 = System.DateTimeOffset.Now;

        // ruleid: no-datetime-now
        var t8 = System.DateTimeOffset.UtcNow;

        // ok: no-datetime-now
        var ok1 = timeProvider.GetUtcNow();

        // ok: no-datetime-now
        var ok2 = timeProvider.GetLocalNow();
    }
}

#endif
