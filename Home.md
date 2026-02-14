---
layout: home
title: Benson's Blog
permalink: /
cover: ./assets/dinosaur.gif
---

## Notes |  Software Development 

> [我為什麼鼓勵工程師寫 blog] by 91
{: .block-tip }

[我為什麼鼓勵工程師寫 blog]: https://tdd.best/blog/why-engineers-should-keep-blogging/

> Writing is nature’s way of letting you know how sloppy your thinking is. 
> Math is nature’s way of letting you know how sloppy your writing is. - Leslie Lamport

Hi, I’m Po-Sheng Hsu (Benson). This blog is a collection of my technical and study notes, mainly focusing on **Software Testing, Compilers, and OS**, and I use Golang, Java, C/C++, and Python for implementation and practice; the purpose of writing is to help me organize my thoughts, build structured knowledge, and internalize what I learn, and I welcome opportunities for information exchange and collaboration.

Hi 我是 Po-Sheng Hsu (許柏勝) Benson，這裡是我的技術與學習筆記，主要關注在**軟體測試、編譯器、作業系統**，並使用 Golang、Java、C/C++、Python 來實作與練習。寫 Blog 的初衷是透過寫作來幫助自己整理思考，建立結構化的知識體系。歡迎與我交換資訊與合作交流。

Benson’s Social Media:
- _Email_: pshsu@csie.io
- _Github_: [Hotshot824](https://github.com/Hotshot824)

<div style="border-top: 1px solid #ccc;"></div>

<section>
  {% if site.posts[0] %}

    {% capture currentyear %}{{ 'now' | date: "%Y" }}{% endcapture %}
    {% capture firstpostyear %}{{ site.posts[0].date | date: '%Y' }}{% endcapture %}
    {% if currentyear == firstpostyear %}
        <h5>This year's posts</h5>
    {% else %}  
        <h5>{{ firstpostyear }}</h5>
    {% endif %}

    {%for post in site.posts %}
      {% unless post.next %}
        <ul>
      {% else %}
        {% capture year %}{{ post.date | date: '%Y' }}{% endcapture %}
        {% capture nyear %}{{ post.next.date | date: '%Y' }}{% endcapture %}
        {% if year != nyear %}
            {% if year != "1970" %}
                </ul>
                <h5>{{ post.date | date: '%Y' }}</h5>
                <ul>
            {% else %}  
                </ul>
                <h5>Without time</h5>
                <ul>
            {% endif %}
        {% endif %}
      {% endunless %}
            {% if year != "1970" %}
                <li><time>{{ post.date | date:"%m/%d" }} - </time>
            {% else %}  
                <li>
            {% endif %}
          <a href="{{ post.url | prepend: site.baseurl | replace: '//', '/' }}">
            {{ post.title }}
          </a>
        </li>
    {% endfor %}
    </ul>

  {% endif %}
</section>