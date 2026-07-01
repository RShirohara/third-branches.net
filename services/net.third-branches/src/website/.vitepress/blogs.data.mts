import { createContentLoader } from "vitepress";

interface Blog {
  title: string;
  publishedDate: string;
  url: string;
}
declare const data: Blog[];

export { data };

export default createContentLoader("blogs/*.md", {
  transform(rawData) {
    return rawData
      .toSorted((a, b) => {
        return a.url < b.url ? 1 : -1;
      })
      .map((data) => {
        return {
          title: data.frontmatter.title,
          publishedDate: data.frontmatter.created_at.split("T")[0],
          url: data.url,
        };
      });
  },
});
