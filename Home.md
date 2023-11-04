---
layout: home
title: Benson's Blog
permalink: /
cover: https://hotshot824.github.io/assets/dinosaur.gif
---

## Notes |  Software Dev | OS 

Hi, I'm writing simple study notes here, mainly Golang Python Javascript.  
Currently, I’m reading materials related to the Linux Kernel, Compiler, and Software testing.  
I am a graduate student, welcome to exchange information and cooperate with me.

Hi, 我在這裡寫寫簡單的學習筆記，主要寫 Golang Python Javascript。  
目前在讀 Linux Kernel, Compiler, Software testing 相關的資料，  
是一名菸酒生，歡迎與我交換資訊與合作交流。

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
            {% if year != "0000" %}
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
            {% if year != "0000" %}
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