---
title: "Compiler | ANTLR Guide"
author: Benson Hsu
date: 2024-03-08
category: Jekylls
layout: post
tags: [Compiler]
---

> ANTLR (ANother Tool for Language Recognition) 是一個強大的 Parser Generator，可以用來產生語法分析器，並且可以用來產生語法分析樹，
> 並且在一些商業或開源程式中被使用，例如: 
> - Eclipse Modeling Framework, 就使用 ANTLR 來將程式碼轉換為 OCL (Object Constraint Language)  
> - PrestoDB 也使用 ANTLR 來解析 SQL  
{: .block-tip }

### ANTLR in Maven

> [ANTLR v4 Maven] 這邊是 ANTLR v4 Maven 的官方文件，可以參考這個文件來使用

Maven 中有幾個 ANTLR 相關的 Plugin 可以使用:
-   ANTLR 4 Maven Plugin: 最完整的 ANTLR Maven Plugin，可以在 Maven 中使用 ANTLR4
-   ANTLR 4 Runtime Maven: 只包含 ANTLR 4 Runtime 的部分
-   ANTLR 4 Tool

**Maven Configuration:**  
下面的範例使用了 ANTLR 4 Maven Plugin，讓 ANTLR 加入到 Maven 的 Build 週期中
-   sourceDirectory: ANTLR 原始檔案的位置
-   outputDirectory: ANTLR 產生的檔案的位置
-   可以輸入 `mvn org.antlr:antlr4-maven-plugin:help -Ddetail=true` 來查看 ANTLR 4 Maven Plugin 的詳細資訊
    -   這邊會列出 configuration 的詳細資訊，反而比 antlr4-maven-plugin 官方文件詳細

```xml
<plugins>
    <plugin>
        <groupId>org.antlr</groupId>
        <artifactId>antlr4-maven-plugin</artifactId>
        <version>4.13.1</version>
        <configuration>
            <listener>true</listener>
            <visitor>true</visitor>
            <sourceDirectory>src/main/java</sourceDirectory>
            <outputDirectory>src/main/generated-sources</outputDirectory>
        </configuration>
        <executions>
            <execution>
                <id>antlr</id>
                <goals>
                    <goal>antlr4</goal>
                </goals>
            </execution>
        </executions>
    </plugin>
</plugins>
```

**ANTLR Command Line Options:**
-   如果不使用 Maven 提供的 configuration，可以直接在 pom.xml 中加入 ANTLR4 的參數
    -   這部分就跟 [ANTLR Command Line] 的參數輸出一樣，可以直接在這邊輸入

    ```xml
    <configuration>
        <arguments>
            <argument>-package</argument>
            <argument>ocl.runner</argument>
            <argument>-o</argument>
            <argument>${project.basedir}/src/generated-sources</argument>
        </arguments>
    </configuration>
    ```

把上面設定好就可以再 Maven 的建置中使用 ANTLR 產生一個語法分析器了，通常會在 Java 中 import ANTLR 的相關工具，
所以建議是在 dependency 也加入 `antlr4-maven-plugin` 或 `antlr4-runtime`。

---

### Parser Generation and Execution

通常不會把 ANTLR 產生的檔案與原始檔案放在一起，這樣在管理上會比較麻煩，所以通常會把 ANTLR 產生的檔案放在另一個 Directory。
-   這邊選擇把 ANTLR 產生的檔案放在 java 的同層目錄下的 `generated-sources` 中
-   因為多了一個地方存放 Java source code，所以可以使用 `build-helper-maven-plugin` 來幫助 Maven 來找到這些 source code

如果這些設定都完成了，就可以在 antlr4 的 sourceDirectory 中加入 grammar file 了，這邊以下面的語法為例:

```antlr4
grammar Expr;		
prog:	expr EOF ;
expr:	expr ('*'|'/') expr
    |	expr ('+'|'-') expr
    |	INT
    |	'(' expr ')'
    ;
NEWLINE : [\r\n]+ -> skip;
INT     : [0-9]+ ;
```

> 加入這個 grammar file 到 sourceDirectory 中，然後執行 `mvn clean install` 就可以看到 ANTLR 產生的語法分析器了

在 java 中添加一個 main function 來測試 ANTLR 產生的語法分析器，如下:

```java
public class Expr {
    public static void main(String [] args) throws Exception
    {
        CharStream charStream = CharStreams.fromString("10+20*30");

        // Make lexer
        ExprLexer lexer = new ExprLexer(charStream);
        // Get a TokenStream on the lexer
        CommonTokenStream tokens = new CommonTokenStream( lexer );
        // Make a parser attached to the token stream
        ExprParser parser = new ExprParser( tokens );
        // Get the top node (the root) of the parse tree then print it
        ParseTree tree = parser.prog();
        System.out.println(tree.toStringTree(parser));
    }
}
```

執行 `mvn exec:java -Dexec.mainClass="{YourMainClass}"` 就可以看到 ANTLR 產生的語法分析樹了，也可以在 `pom.xml` 中加入 `exec-maven-plugin` 來執行這個 main function。

---

### ANTLR Command Line

ANTLR 也有提供一系列 Command Line 的指令，可以用來進行產生語法分析器跟 GUI 的 Parser Tree，下面是安裝步驟:

```bash
wget https://www.antlr.org/download/antlr-4.13.1-complete.jar
mv antlr-4.13.1-complete.jar /opt/javalib/

vim ~/.bashrc 
# Join the following to the .bashrc file
# export JAVA_HOME=/opt/jdk-17.0.10
# export PATH=$JAVA_HOME/bin:$PATH
# export CLASSPATH=/opt/javalib/antlr-4.13.1-complete.jar
# alias antlr4='java -jar /opt/javalib/antlr-4.13.1-complete.jar'
# alias grun='java org.antlr.v4.gui.TestRig'

source ~/.bashrc

antlr4
# [benson@arch ~]$ antlr4 
# ANTLR Parser Generator  Version 4.13.1
#  -o ___              specify output directory where all output is generated
#  -lib ___            specify location of grammars, tokens files
#  ...
#  -Xexact-output-dir  all output goes into -o dir regardless of paths/package
```

> ##### Last Edit
> 03-19-2024 19:32
{: .block-warning }

[ANTLR v4 Maven]: https://www.antlr.org/api/maven-plugin/latest/usage.html
[ANTLR Command Line]: https://gist.github.com/subchen/464b05ee611bce031984