// SPDX-FileCopyrightText: 2026 lusoris <lusoris@pm.me>
// SPDX-License-Identifier: GPL-3.0-or-later

#if SEMGREP_FIXTURE

using System;
using System.Reflection;

namespace TestData;

public class TestAssemblyLoad
{
    public void Run()
    {
        // ruleid: no-assembly-load
        Assembly.Load("Plugin");

        // ruleid: no-assembly-load
        Assembly.LoadFrom("Plugin.dll");

        // ruleid: no-assembly-load
        Assembly.LoadFile("/path/Plugin.dll");

        // ruleid: no-assembly-load
        System.Reflection.Assembly.Load("Plugin");

        // ruleid: no-assembly-load
        Activator.CreateInstance("PluginAssembly", "PluginType");

        // ruleid: no-assembly-load
        System.Activator.CreateInstance("PluginAssembly", "PluginType");

        // ok: no-assembly-load
        var ok1 = Activator.CreateInstance(typeof(TestAssemblyLoad));

        // ok: no-assembly-load
        var ok2 = Activator.CreateInstance<TestAssemblyLoad>();
    }
}

#endif
