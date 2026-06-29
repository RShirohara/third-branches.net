export default {
  async fetch(request: Request): Promise<Response> {
    const url = URL.parse(request.url);
    const path = url?.pathname ?? "/";

    // Web Key Directory support.
    if (path.match("^/.well-known/openpgpkey/policy")) {
      return new Response(null, { status: 200 });
    }
    if (path.match("^/.well-known/openpgpkey/hu")) {
      const mail_provider_domain = "proton.me";
      const mail_provider_wkd_domain = `openpgpkey.${mail_provider_domain}`;
      const response = await fetch(
        `https://${mail_provider_wkd_domain}` +
          path.replace("/openpgpkey", `/openpgpkey/${mail_provider_domain}`) +
          (url?.search ?? ""),
      );
      return new Response(response.body, {
        headers: {
          "access-control-allow-origin": "*",
          "content-type":
            response.headers.get("content-type") ?? "text/plain; charset=UTF-8",
          "content-transfer-encoding":
            response.headers.get("content-transfer-encoding") ?? "",
          "content-disposition":
            response.headers.get("content-disposition") ?? "",
        },
        status: response.status,
        statusText: response.statusText,
      });
    }

    return new Response("Not found", { status: 404 });
  },
};
