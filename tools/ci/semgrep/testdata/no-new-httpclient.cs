// SPDX-FileCopyrightText: 2026 lusoris <lusoris@pm.me>
// SPDX-License-Identifier: GPL-3.0-or-later

#if SEMGREP_FIXTURE

using System.Net.Http;

namespace TestData;

public class TestHttpClient
{
    public void Run(IHttpClientFactory factory)
    {
        // ruleid: no-new-httpclient
        var client1 = new HttpClient();

        // ruleid: no-new-httpclient
        var client2 = new System.Net.Http.HttpClient();

        // ok: no-new-httpclient
        var okClient = factory.CreateClient();
    }
}

#endif
