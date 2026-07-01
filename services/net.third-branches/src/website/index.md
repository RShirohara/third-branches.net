<script setup>
import { data as blogs } from "./.vitepress/blogs.data.mts"
</script>

# 第三支流

> [!NOTE]
> 永遠に工事中。

## 身分証明

- [Ray Shirohara (城原 零)](/identities/ray-shirohara)
- [Rei Shiroto (白戸 レイ)](/identities/rei-shiroto)

## 記事

<ul>
  <li v-for="blog of blogs">
    <a :href="blog.url">{{ blog.publishedDate }}: {{ blog.title }}</a>
  </li>
</ul>
