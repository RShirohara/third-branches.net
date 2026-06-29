import { defineConfig } from "vitepress";

// Ref: <https://vitepress.dev/reference/site-config>
export default defineConfig({
  title: "第三支流",
  lang: "ja-JP",
  themeConfig: {
    sidebar: [
      {
        text: "Home",
        link: "/",
      },
      {
        text: "Identities",
        items: [],
      },
    ],
  },
  outDir: "../../dist/website",
});
