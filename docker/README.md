# Docker 拙见

Docker(moby) GitHub: **https://github.com/moby/moby** 基于Go语言。2017年年初，docker公司将原先的docker项目改名为moby，并创建了docker-ce(开源项目)和docker-ee(闭源项目)。

Docker 官网：**https://www.docker.com**  Docker安装、使用、文档等

Docker Hub：**https://hub.docker.com** 搜索镜像，获取镜像说明、使用方式和常用配置，也可获取镜像的Dockerfile内容

**推荐书籍**：*《Lucene实战(第2版)》*，大部分样例与该书籍对应

#  什么是容器

# 虚拟化和容器

# 主流的容器技术有哪些

# Paas(Platform as a Service) 和 Caas(Container as a Service)，容器云(阿里云，华为云，腾讯云)

#  docker是什么

#  为什么要了解docker，docker能给我提供什么

# docker入门（概念）

# docker环境搭建和使用

# docker的网络

# docker使用中的小坑

# docker & jenkins

## jenkins容器

## jenkins使用docker

## jenkins容器中使用宿主机docker(Docker-in-Docker for CI)

# Dockerfile最佳实践，参考学习别人的Dockerfile书写

# java代码自动打包jar的镜像方式

## Dockerfile

## maven plugin of docker

# 集群、编排：容器编排技术有哪些，各自特点，以及后续学习推荐

- 容器集群并不是许多容器的简单堆积，而是以容器技术为基础的包含部署、调度、网
  络、存储等方面的有机整体。在容器集群之上可以构建更高层的服务系统 ，如动态伸缩的
  任务队列服务、企业级的业务平台、分布式的数据计算服务等。作为底层计算资源和上层
  业务服务的都合剂，以按需使用的方式提供基于容器的云端运行环境的平台，形成了 一种
  具有独特价值的服务，这类场景被称为容器即服务 。
 
 
Apache Lucene是一个完全用Java编写的高性能，功能齐全的文本搜索引擎库。 它是一种适用于几乎所有需要全文搜索的应用程序的技术，尤其是跨平台搜索。
Apache Lucene是一个可供免费下载的开源项目。 请使用右侧的链接访问Lucene。

**Lucene 的三大组件：索引、搜索、分析**

# 1 索引

    参考 IndexUtil 和 测试用例 QueryTest

## 1.1 Directory

Directory 是一个平面的文件列表。 文件可以在创建时写入一次。 创建文件后，只能打开文件进行读取或删除。 在读写时都允许随机访问。Java的i/o API不直接使用，而是所有i/o都通过此API。
 
这允许以下内容：实施基于RAM的指数;通过JDBC存储在数据库中的实现索引;将索引实现为单个文件;目录锁定由LockFactory实例实现。

### 1.1.1 FSDirectory

    参考 测试用例 FilterTest
    
用于在文件系统中存储索引文件的Directory实现的基类。目前有三个核心子类：
- SimpleFSDirectory 是使用Files.newByteChannel的简单实现。但是，它具有较差的并发性能（多个线程将成为瓶颈），因为当多个线程从同一文件读取时它会同步。
- NIOFSDirectory 在读取时使用java.nio的FileChannel的位置io，以避免从同一文件读取时的同步。不幸的是，由于仅支持Windows的Sun JRE错误，这对于Windows来说是一个糟糕的选择，但在所有其他平台上，这是首选。
  使用Thread.interrupt()或Future.cancel(boolean)的应用程序应该使用RAFDirectory。有关详细信息，请参阅NIOFSDirectory java doc。
- MMapDirectory 在读取时使用内存映射IO。如果您有相对于索引大小的大量虚拟内存，这是一个不错的选择，例如，如果您运行的是64位JRE，或者您运行的是32位JRE，但您的索引大小足够小以适应虚拟记忆空间。 
  Java目前存在无法从用户代码中取消映射文件的限制。当GC释放字节缓冲区时，文件将被取消映射。由于Sun的JRE中存在此错误，MMapDirectory的IndexInput.close()无法关闭底层的OS文件句柄。
  只有当GC最终收集底层对象时（可能会在一段时间之后），才会关闭文件句柄。这将消耗额外的瞬态磁盘使用：在Windows上，尝试删除或覆盖文件将导致异常;在其他平台上，通常具有“最后关闭时删除”语义，
  而这样的操作将成功，字节仍占用磁盘上的空间。对于许多应用程序，此限制不是问题（例如，如果您有足够的磁盘空间，并且您不依赖于在Windows上覆盖文件），但它仍然是一个重要的限制需要注意。
  此类提供了错误报告中提到的（可能是危险的）变通方法，该方法可能在非Sun JVM上失败。
  
不幸的是，由于系统的特殊性，没有单一的整体最佳实现。因此，我们添加了open(java.nio.file.Path)方法，以允许Lucene根据您的环境选择最佳的FSDirectory实现，以及每个实现的已知限制。
对于没有理由喜欢特定实现的用户，最好只使用open(java.nio.file.Path)。对于所有其他人，您应该直接实例化所需的实现。

**注意**：如果在线程被IO阻塞的同时，在线程中断时直接或间接地从线程访问上述子类之一可以立即关闭底层通道。通道将保持关闭状态，随后对索引的访问将引发ClosedChannelException。
使用Thread.interrupt()或Future.cancel(boolean)的应用程序应该使用misc Lucene模块中较慢的传统RAFDirectory。
锁定实现默认为NativeFSLockFactory，但可以通过传入自定义LockFactory实例来更改。
      
## 1.2 IndexWriter

IndexWriter创建并维护索引。
  
## 1.3IndexWriterConfig

保存用于创建IndexWriter的所有配置。使用此对象创建IndexWriter后，对此对象的更改不会影响IndexWriter实例。 为此，请使用从IndexWriter.getConfig()返回的LiveIndexWriterConfig。
  
## 1.4 Document
文档是索引和搜索的单位。文档是一组字段。每个字段都有一个名称和一个文本值。字段可以与文档一起存储，在这种情况下，它与文档上的搜索命中一起返回。因此，每个文档通常应包含一个或多个唯一标识它的存储字段。
**注意**：未存储的字段在从索引检索的文档中不可用，例如，使用ScoreDoc.doc或IndexReader.document(int)。

## 1.5 Field

专家：直接为文档创建字段。大多数用户应该使用其中一个语法糖子类：

- TextField：为全文搜索编制索引的Reader或String
- StringField：字符串逐字索引为单个标记
- IntPoint：int为精确/范围查询编制索引。
- LongPoint：长索引精确/范围查询。
- FloatPoint：float为精确/范围查询建立索引。
- DoublePoint：对精确/范围查询进行双索引。
- SortedDocValuesField：byte []按列索引进行排序/分面
- SortedSetDocValuesField：SortedSet <byte []>按列索引以进行排序/分面
- NumericDocValuesField：用于排序/分面的长列索引
- SortedNumericDocValuesField：SortedSet <long>按列索引以进行排序/分面
- StoredField：用于在摘要结果中检索的仅存储值
    
字段是文档的一部分。每个字段有三个部分：名称，类型和值。值可以是文本（字符串，读取器或预分析的TokenStream），二进制（byte []）或数字（数字）。字段可选地存储在索引中，以便可以使用文档上的命中返回它们。

**注意**：字段类型是IndexableFieldType。更改IndexableFieldType的状态将影响它所使用的任何字段。强烈建议在字段实例化后不进行任何更改。

## 1.6 IndexReader

IndexReader是一个抽象类，提供用于访问索引的时间点视图的接口。在打开新的IndexReader之前，通过IndexWriter对索引所做的任何更改都不可见。如果您的IndexWriter正在进行中，最好使用DirectoryReader.open(IndexWriter)来获取IndexReader。

当您需要重新打开以查看对索引的更改时，最好使用DirectoryReader.openIfChanged(DirectoryReader)，因为新读者将尽可能与前一个读者共享资源。索引的搜索完全通过此抽象接口完成，因此任何实现它的子类都是可搜索的。
  
有两种不同类型的IndexReader：
- LeafReader：这些索引不包含几个子读取器，它们是原子的。它们支持检索存储的字段，文档值，术语和发布。
- CompositeReader：此阅读器的实例（如DirectoryReader）只能用于从底层LeafReader获取存储的字段，但不能直接检索发布。为此，请通过CompositeReader.getSequentialSubReaders（）获取子读取器。
  
磁盘上索引的IndexReader实例通常是通过调用其中一个静态DirectoryReader.open()方法构建的，例如， DirectoryReader.open(org.apache.lucene.store.Directory)。DirectoryReader实现CompositeReader接口，不可能直接获取发布。
  
为了提高效率，在此API文档中通常通过文档编号引用，非负整数，每个都在索引中命名一个唯一的文档。这些文档编号是短暂的 - 它们可能会随着文档添加到索引中或从索引中删除而更改。因此，客户端不应该依赖于会话之间具有相同编号的给定文档。
    
**注意**：IndexReader实例是完全线程安全的，这意味着多个线程可以同时调用其任何方法。如果您的应用程序需要外部同步，则不应在IndexReader实例上进行同步;使用您自己的（非Lucene）对象。


# 2 搜索

IndexSearcher 结合常用Query、常用Filter、常用Sort的使用
    
    参考 SearchUtil 和 测试用例 QueryTest

## 2.1 IndexSearcher

实现对单个IndexReader的搜索。

应用程序通常只需要调用继承的 search(Query, int)方法。出于性能原因，如果您的索引不变，您应该跨多个搜索共享一个IndexSearcher实例，而不是每次搜索创建一个新的。 
如果索引已更改并且您希望查看搜索中反映的更改，则应使用DirectoryReader.openIfChanged(DirectoryReader)获取新的读取器，然后从中创建新的IndexSearcher。 
此外，对于低延迟周转，最好使用近实时读取器（DirectoryReader.open(IndexWriter)）。一旦你有了一个新的IndexReader，从它创建一个新的IndexSearcher相对便宜。

**注意**：IndexSearcher实例完全是线程安全的，这意味着多个线程可以同时调用其任何方法。如果您的应用程序需要外部同步，则不应在IndexSearcher实例上进行同步; 使用您自己的（非Lucene）对象。
  
## 2.2TopDocs

表示 IndexSearcher.search(Query,int) 返回的 hits (匹配结果)
    
## 2.3 ScoreDoc

TopDocs中的一个 hit (匹配结果)。
    
## 2.4 Query

    参考测试用例 QueryTest
    
- TermQuery 项搜索(术语查询)
- TermRangeQuery 项范围查询(术语范围查询)
- NumericRangeQuery 数字范围查询(新版本使用 PointRangeQuery 替代)
- PrefixQuery 前缀查询
- BooleanQuery 组合查询
    - MUST 与 MUST 组合表示交集关系
    - MUST 与 MUST_NOT 组合表示包含与不包含关系
    - MUST_NOT 与 MUST_NOT 组合是没有任何意义的，所以不要错误搭配使用
    - SHOULD 与 MUST 组合表示MUST，相当于SHOULD就没有任何价值
    - SHOULD 与 MUST_NOT 组合相当于MUST与MUST_NOT的关系
    - SHOULD 与 SHOULD 组合表示逻辑或
- PhraseQuery 短语查询(若搜索范围只用10个，slop置为12其实就是绕了一圈，也通过此方式实现倒排索引)
- WildcardQuery 通配符查询
- FuzzyQuery 模糊查询
-  MatchAllDocsQuery 匹配所有查询

### 其他高级查询

- MultiPhraseQuery 多短语查询
- RegexpQuery 正则表达式查询
- ConstantScoreQuery
- DisjunctionMaxQuery
- SpanQuery 跨度查询 是一种计算密集型操作 参考 SpanQueryTest

span是由类Spans枚举的<doc，startPosition，endPosition>元组。
    
以下是实现跨度查询运算符的实现类：
- SpanTermQuery 匹配包含特定Term的所有跨度。这不应该用于在Integer.MAX_VALUE位置编入索引的术语。
    和其他跨度查询类型结合使用，单独使用时相当于TermQuery
    
- SpanNearQuery 匹配彼此靠近的跨度，可用于实现短语搜索（从SpanTermQuerys构造时）和短语间接近（从其他SpanNearQuerys构造时）。
    用来匹配临近的跨度
    
- SpanWithinQuery 匹配在另一个跨度内发生的跨度。

- SpanContainingQuery 匹配包含另一个跨度的跨度。

- SpanOrQuery 合并来自许多其他SpanQuerys的跨度。
    跨度查询聚合匹配
    
- SpanNotQuery 删除匹配一个SpanQuery的跨距，该跨度与另一个跨越（或接近）。这可以用于例如实现段内搜索。
    用来匹配不重叠的跨度
    
- SpanFirstQuery 匹配跨度q的结尾位置小于n。这可用于将匹配约束到文档的第一部分。
    用来匹配域中首部分的各个跨度，对出现在域中开始某位置范围内进行跨度查询匹配
    
- SpanPositionRangeQuery 是SpanFirstQuery的更通用形式，可以将匹配约束到文档的任意部分。

- FieldMaskingSpanQuery SpanQuery类家族一员，封装其他SpanQuery类，但程序会任务已匹配到另外的域。该功能可用于针对多个域的跨度查询。

在所有情况下，输出范围都是最低限度的。换句话说，通过匹配x和y中的跨度而形成的跨度从两个开始中的较小者开始并且在两个末端中的较大者处结束。

**通过 QueryParser 将输入结果解析成对应的 Query 供搜索使用**
  
## 2.5 Filter 

    参考测试用例  FilterTest
    
过滤搜索
- TermRangeFilter 项范围过滤(术语范围过滤)
- NumericRangeFilter 数字范围过滤
- FieldCacheRangeFilter 使用域缓存机制的范围过滤(有上两者功能)
- FieldCacheTermsFilter 特定项过滤
- QueryWrapperFilter 对常用Query封装的过滤
- SpanQueryFilter 对常用SpanQuery封装的过滤
- BooleanQuery 组合查询过滤
- PrefixFilter 前缀过滤
- CachingWrapperFilter 缓存过滤结果
- ConstantScoreQuery 将过滤器转换成查询以用于随后的搜索
    
## 2.6 Sort 

    参考测试用例 SortTest
    
封装返回匹配的排序条件。

必须仔细选择用于确定排序顺序的字段。 文档必须在此类字段中包含单个术语，并且术语的值应指示文档在给定排序顺序中的相对位置。 
该字段必须编入索引，但不应该被标记化，并且不需要存储（除非您碰巧需要将其与其余的文档数据一起使用）。
  
## 2.7 Collector

专家：收集器主要用于从搜索中收集原始结果，并实现排序或自定义结果过滤，整理等。
  
Lucene的核心收集器派生自Collector和SimpleCollector。可能您的应用程序可以使用其中一个类或子类TopDocsCollector，而不是直接实现Collector：
- TopDocsCollector是一个抽象基类，假设您在收集完成后根据某些条件检索前N个文档。

- TopScoreDocCollector是一个具体的子类TopDocsCollector，并根据score + docID进行排序。这由IndexSearcher搜索方法在内部使用，不采用显式排序。它可能是最常用的收集器。

- TopFieldCollector子类TopDocsCollector并根据指定的Sort对象进行排序（按字段排序）。这由IndexSearcher搜索方法在内部使用，采用显式排序。

- TimeLimitingCollector，它包装任何其他收集器，如果占用太多时间则中止搜索。

- PositiveScoresOnlyCollector包装任何其他收集器并阻止收集分数<= 0.0的命中

## 2.8 Scorer

专家：针对不同类型查询的通用评分功能。

Scorer按照doc Id的递增顺序在匹配查询的文档上公开迭代器。 使用给定的相似性实现来计算文档分数。
**注意**：值Float.Nan，Float.NEGATIVE_INFINITY和Float.POSITIVE_INFINITY不是有效分数。 某些收集器（例如TopScoreDocCollector）无法正确收集具有这些分数的命中。

# 3 高级搜索

## 3.1 段对应的reader

## 3.2 扩展 QueryParser 类

剔除 QueryParser 中 WildcardQuery 和 FuzzyQuery 对性能的影响，PhraseQuery 的 slop 过大时对 Term 的顺序问题(替换为 SpanNearQuery)，
以及不支持 NumberRangeQuery 问题的处理。

    参考 SmartQueryParse 和测试用例 QueryTest
  
## 3.3 自定义 Filter 和 FilteredQuery结合使用

    参考 SpecialFilter 和测试用例
  
## 3.4 自定义 FieldComparatorSource 和 自定义 FieldComparator 实现自定义排序
    
    参考 DistanceComparatorSource 和测试用例 SortTest

## 3.5 自定义 Collector 收集器

  编写自定义的Colletor，可以对搜索返回的文档实现更精确的控制。 
     
    参考 CollectorAdapter、AllDocCollector、FileSizeCollector 和测试用例 CollectorTest

## 3.6 自定义 CustomScoreQuery 和 CustomScoreProvider 评分规则

    参考 RecentFileScoreQuery 和测试用例 FuctionScoreTest

## 3.7 有效载荷 Payloads 参考 BulletinPayloadsTest PayloadTest 

有效载荷是Lucene一个高级功能，它使应用程序能够针对索引期间出现的项保存任意数量的字节数组。该字节数组对于Lucene是完全不透明的：
它只是在索引期间简单存储每个项的位置信息，然后将这些信息用于随后的搜索。另外，Lucene核心功能模块并不适用有效载荷进行任何操作，
也不对这些内容作出任何假设。这意味着你可以存储任意数量的对程序较为重要的编码数据，并在随后的搜索中使用这些数据，或者在程序中
判断哪些文档存在于搜索结果中，或者判断这些匹配文档是如何进行评分和排序的。

有效载荷有多种用途。

**关联类**
- Payload 有效载荷实例
- PayloadAttribute 有效载荷属性
- PayloadHelper 提供静态方法，将int和float类型编码和解码成byte数组类型的有效载荷
- Similarity 定义了 Lucene 评分的组成部分的抽象类
- DefaultSimilarity Similarity 的默认继承子类

## 3.8 注意：

### 3.8.1域缓存

Lucene的域缓存是一个高级的内部API，创建她的目的就是为了满足性能问题

- 域缓存只能用于包含单个项的域(即不能被分词)，这通常意味着该域在被索引时需要使用参数 Index.NOT_ANALYZED 或 Index.NOT_ANALYZED_NO_NORMS，
    如果使用诸如 KeywordAnalyzer 等分析器的话，这些域还是可以被分析的，该分析过程只产生一个语汇单元
- 域缓存会消耗大量内存；每条数据都需要为之分配一个本地类型数组，该数组长度与对应reader中的文档数量相等，
    只有当程序关闭reader并删除其对应的所有引用并且程序启动垃圾收集任务时，域缓存的内容才会被清除。


# 5 分析

    参考 AnalyzerUtil 和测试用例 AnalyzerUtilTest

##  分析流程：
    Reader -> Tokenizer -> TokenFilter1 -> ... -> TokenFilterN -> Tokens
## 5.1 Analyzer
分析器构建TokenStreams，用于分析文本。 因此，它代表了从文本中提取索引术语的策略。

为了定义完成的分析，子类必须在createComponents(String(中定义它们的 TokenStreamComponents。 然后在每次调用tokenStream(String，Reader)时重用这些组件。

常用子类有：
- WhitespaceAnalyzer
- SimpleAnalyzer
- StopAnalyzer
- StandardAnalyzer
    
## 5.2 Tokenizer (TokenStream 子类) 

Tokenizer是TokenStream，其输入是Reader。

这是一个抽象的类; 子类必须覆盖TokenStream.incrementToken()

**注意**：重写TokenStream.incrementToken()的子类必须在设置属性之前调用AttributeSource.clearAttributes()。

常用子类有：
- WhitespaceTokenizer
- SimpleTokenizer
- StopTokenizer
- StandardTokenizer
    
## 5.3 TokenFilter (TokenStream 子类) 

TokenFilter是TokenStream，其输入是另一个TokenStream。

这是一个抽象的类; 子类必须覆盖TokenStream.incrementToken()。

常用子类有：
- WhitespaceFilter
- SimpleFilter
- StopFilter
- StandardFilter
  
  
## 5.4 Attribute

常用子类有：
- CharTermAttribute Token的术语文本
- OffsetAttribute Token字符的开始和结束偏移量
- PositionIncrementAttribute Token的位置增量
- TypeAttribute Token的类型

其他不常用子类有
- BytesTermAttribute
- FlagsAttribute
- KeywordAttribute
- PayloadAttribute
- PositionLengthAttribute
- TermFrequencyAttribute
- TermToBytesRefAttribute
 
# 6 高亮显示显示查询项 

    参考测试用例 HighlighterTest
    
## 6.1 Scorer

## 6.2 Fragmenter

## 6.3 Formatter

## 6.4 Highlighter

## 6.5 FastVectorHighlighter