// SPDX-FileCopyrightText: 2026 lusoris <lusoris@pm.me>
// SPDX-License-Identifier: GPL-3.0-or-later

#if SEMGREP_FIXTURE

using System.Diagnostics;

namespace TestData;

public class TestProcessStart
{
    public void Run()
    {
        // ruleid: no-process-start
        Process.Start("ls");

        // ruleid: no-process-start
        System.Diagnostics.Process.Start("ls");

        // ruleid: no-process-start
        var psi1 = new ProcessStartInfo("ls");

        // ruleid: no-process-start
        var psi2 = new System.Diagnostics.ProcessStartInfo("ls");

        // ok: no-process-start
        var p = new Process();
    }
}

#endif
