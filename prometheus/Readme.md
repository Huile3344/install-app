# prometheus 

- GitHub
  - [prometheus](https://github.com/prometheus/prometheus)
  - **[example](https://github.com/prometheus/prometheus/tree/main/documentation/examples)**
- **[官网](https://prometheus.io/)**

## 基于k8s的服务发现机制配置 kubernetes_sd_config
- **[官方文档 kubernetes_sd_config 配置](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#kubernetes_sd_config)**
- **[Prometheus之kubernetes_sd_config](https://www.orchome.com/9884)** 可认为是对应官方文档的翻译
- [官方示例: prometheus-kubernetes](https://github.com/prometheus/prometheus/blob/main/documentation/examples/prometheus-kubernetes.yml)

## prometheus 简介

### 什么是 prometheus

Prometheus 是一个开源系统监控和警报工具包，最初构建于 SoundCloud。 自 2012 年成立以来，许多公司和组织都采用了 Prometheus，该项目拥有非常活跃的开发者和用户社区。 它现在是一个独立的开源项目，独立于任何公司进行维护。 为了强调这一点，并澄清项目的治理结构，Prometheus 于 2016 年加入了云原生计算基金会，作为继 Kubernetes 之后的第二个托管项目。

Prometheus 将其指标收集并存储为时间序列数据，即指标信息与记录它的时间戳一起存储，以及称为标签的可选键值对。

### prometheus 特点

prometheus的主要特点是：

- 一个多维数据模型，具有由指标(metric)名称和键/值对标识的时间序列数据
- PromQL，一种利用这种维度的灵活查询语言
- 不依赖分布式存储； 单个服务器节点是自治的
- 时间序列收集通过 HTTP 上的 pull 模型发生
- 通过中间网关支持推送时间序列
- 通过服务发现或静态配置发现目标
- 多种图形和仪表盘支持模式

### 什么是指标(metrics)
用外行人的话说，指标是数字测量，时间序列意味着随着时间的推移记录变化。 用户想要测量的内容因应用程序而异。 对于 Web 服务器，它可能是请求次数，对于数据库，它可能是活动连接数或活动查询数等。

指标在理解您的应用程序以某种方式工作的原因方面发挥着重要作用。 假设您正在运行一个 Web 应用程序并发现该应用程序很慢。 您将需要一些信息来了解您的应用程序发生了什么。 例如，当请求数量很高时，应用程序可能会变慢。 如果您有请求计数指标，您可以找出原因并增加处理负载的服务器数量。

### 组件
Prometheus 生态系统由多个组件组成，其中许多是可选的：
- 主要的 Prometheus 服务器，抓取和存储时间序列数据
- 用于检测应用程序代码的客户端库(client libraries)
- 支持短期工作的推送网关(pushgateway)
- HAProxy、StatsD、Graphite 等服务的专用 exporters。
- 一个警报管理器(alertmanager)用来处理警报
- 各种支持工具
大多数 Prometheus 组件都是用 Go 编写的，这使得它们易于构建和部署为静态二进制文件。

### 架构
下图说明了 Prometheus 的架构及其一些生态系统组件：
![alt 架构图](architecture.png "架构图")
对于短期作业(job)，Prometheus 直接或通过中介推送网关(pushgateway)从检测的作业(job)中抓取(scrape)指标(metrics )。 它将所有抓取的样本(sample)存储在本地，并对这些数据运行规则(rules)，以从现有数据聚合和记录新的时间序列或生成警报。 Grafana 或其他 API 使用者可用于可视化收集的数据。

### 什么时候适合
Prometheus 适用于记录任何纯数字时间序列。它既适合以机器为中心的监控，也适合监控高度动态的面向服务的架构。在微服务的世界中，它对多维数据收集和查询的支持是一个特殊的优势。

Prometheus 是为可靠性而设计的，它是您在中断期间访问的系统，让您能够快速诊断问题。每个 Prometheus 服务器都是独立的，不依赖于网络存储或其他远程服务。当基础架构的其他部分损坏时，您可以依赖它，并且您无需设置大量基础架构即可使用它。

### 什么时候不合适？
Prometheus 重视可靠性。即使在出现故障的情况下，您也可以随时查看有关系统的可用统计信息。如果您需要 100% 的准确性，例如按请求计费，Prometheus 不是一个好的选择，因为收集的数据可能不够详细和完整。在这种情况下，您最好使用其他系统来收集和分析计费数据，并使用 Prometheus 进行其余的监控。


## Prometheus 基本概念

### 时间序列
时间序列是按照时间排序的一组随机变量，它通常是在相等间隔的时间段内依照给定的采样率对某种潜在过程进行观测的结果。时间序列数据本质上反映的是某个或者某些随机变量随时间不断变化的趋势，而时间序列预测方法的核心就是从数据中挖掘出这种规律，并利用其对将来的数据做出估计

### 数据模型
Prometheus 从根本上将所有数据存储为时间序列(time series)：属于同一指标和同一组标签维度的带时间戳的值流。除了存储的时间序列，Prometheus 可能会生成临时派生的时间序列作为查询的结果。

**注意**：针对现有的时间序列进行操作，将产生新的时间序列，即其结果值


#### 指标名称和标签(Metric names and labels)
每个时间序列都由其指标名称(metric name)和称为标签(labels)的可选键值对唯一标识。

指标名称指定了被测量的系统的一般特征（例如  `http_requests_total` - 收到的 HTTP 请求总数）。它可能包含 ASCII 字母和数字，以及下划线和冒号。它必须与正则表达式 `[a-zA-Z_:][a-zA-Z0-9_:]*` 匹配。

**注意**：冒号是为用户定义的记录规则保留的。exporters 或 直接仪表(instrumentation) 不应使用它们。

标签启用 Prometheus 的维度数据模型：相同指标名称的任何给定标签组合标识该指标的特定维度实例（例如：所有使用 `POST` 方法发送到 `/api/tracks` 处理程序的 HTTP 请求）。查询语言允许基于这些维度进行过滤和聚合。更改任何标签值，包括添加或删除标签，都会创建一个新的时间序列。

标签名称可以包含 ASCII 字母、数字和下划线。它们必须匹配正则表达式 `[a-zA-Z_][a-zA-Z0-9_]*`。以 __ 开头的标签名称保留供内部使用。

标签值可以包含任何 Unicode 字符。

**带有空标签值的标签被认为等同于不存在的标签。**

另请参阅 [命名指标和标签的最佳实践](https://prometheus.io/docs/practices/naming/) 。

示例：
```
node_cpu_seconds_total{cpu="0", instance="10.0.2.18:9100", job="node-exporter", mode="idle", node_exporter="tasks.node-exporter"}
node_cpu_seconds_total{cpu="0", instance="10.0.2.18:9100", job="node-exporter", mode="iowait", node_exporter="tasks.node-exporter"}
```
以上示例，指标名称是 `node_cpu_seconds_total`, 其使用的标签名称有：`cpu`、`instance`、`job`、`mode`、`node_exporter`，
但是其 `mode` 标签名称的值分别是 `idle` 和 `iowait` ，因此是两个不同的时间序列，而不是一个时间序列


#### 样本(Samples)
样本构成了实际的时间序列数据。每个样本包括：
- 一个 float64 值
- 毫秒精度的时间戳

示例:
```
[1628043840.347, "1608591.21"]
# 第一个是时间戳，第二个是 float64 值
```

#### 数据格式
```
<------------------metric------------------->@<-timestamp->=><-value->
http_request_total{status="200",method="GET"}@1434417560938=>94355
```

#### 符号(Notation) 表示形式
给定一个指标名称和一组标签，时间序列经常使用以下符号标识：
```
<metric name>{<label name>=<label value>, ...}
```
例如，具有标名称 `api_http_requests_total` 和标签 `method="POST"` 和 `handler="/messages"` 的时间序列可以这样写：
```
api_http_requests_total{method="POST", handler="/messages"}
```
这与 OpenTSDB 使用的符号相同。

### 指标类型
#### 概括
Prometheus 客户端库提供四种核心指标类型。这些目前仅在客户端库（以启用针对特定类型的使用而定制的 API）和有线协议中有所不同。 Prometheus 服务器尚未使用类型信息并将所有数据扁平化为无类型时间序列。这在未来可能会改变。

#### Counter
counter 是一个累积指标，表示单个单调递增的计数器，其值只能增加或在重新启动时重置为零。例如，您可以使用计数器来表示服务的请求数、完成的任务数或错误数。

不要使用计数器来公开可以减少的值。例如，不要对当前运行的进程数使用计数器；而是使用 gauge。

计数器的客户端库使用文档：

#### Gauge
gauge 是表示可以任意上下波动的单个数值的指标。

gauge 通常用于测量值，如温度或当前内存使用情况，但也用于可以上下波动的“计数”，如并发请求的数量。

#### 直方图(Histogram)
histogram 对观察进行采样（通常是请求持续时间或响应大小之类的内容）并将它们计算在可配置的桶中。它还提供所有观测值的总和。

基本指标名称为 `<basename>` 的直方图在抓取期间公开多个时间序列：

- 观察桶的累积计数器，公开为 `<basename>_bucket{le="<upper inclusive bound>"}`
- 所有观测值的总和，公开为 `<basename>_sum`
- 已观察到的事件计数，公开为 `<basename>_count`（与上面的 `<basename>_bucket{le="+Inf"}` 相同）
使用 `histogram_quantile()` 函数从直方图甚至直方图的聚合 计算分位数。直方图也适用于计算 Apdex 分数。在对桶进行操作时，请记住直方图是累积的。有关直方图用法和与摘要的差异的详细信息，请参阅 [histograms and summaries](https://prometheus.io/docs/practices/histograms) 。


#### 摘要(Summary)
与直方图类似，摘要样本观察（通常是请求持续时间和响应大小之类的东西）。虽然它还提供观察的总数和所有观察值的总和，但它计算滑动时间窗口内的可配置分位数。

基本指标名称为 `<basename>` 的摘要在抓取期间公开多个时间序列：
- 观察事件的流式 **φ-quantiles** (0 ≤ φ ≤ 1)，暴露为 `<basename>{quantile="<φ>"}`
- 所有观测值的总和，公开为 `<basename>_sum`
- 已观察到的事件计数，公开为 `<basename>_count`
有关 φ-quantiles、摘要用法以及与直方图差异的详细说明，请参阅 [histograms and summaries](https://prometheus.io/docs/practices/histograms) 。



### 作业和实(JOBS AND INSTANCES)
在 Prometheus 术语中，您可以抓取的端点称为实例(instance)，通常对应于单个进程。具有相同目的的实例集合，例如为了可伸缩性或可靠性而复制的过程，称为作业(job)。

例如，具有四个副本实例(instance)的 API 服务器作业(job)：

- 工作(job)：`api-server`
    - 实例(instance) 1：`1.2.3.4:5670`
    - 实例(instance) 2：`1.2.3.4:5671`
    - 实例(instance) 3：`5.6.7.8:5670`
    - 实例(instance) 4：`5.6.7.8:5671`
    
#### 自动生成的标签和时间序列
当 Prometheus 抓取目标时，它会自动将一些标签附加到抓取的时间序列上，用于识别抓取的目标：
- `job`：目标所属的配置作业名称。
- `instance` 实例： `<host>:<port>` 部分是被抓取目标的URL。
如果这些标签中的任何一个已经存在于抓取的数据中，则行为取决于 `honor_labels` 配置选项。有关更多信息，请参阅 [抓取配置文档](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config) 。

对于每个实例抓取，Prometheus 在以下时间序列中存储一个样本：

- `up{job="<job-name>", instance="<instance-id>"}`：如果实例健康，即可达，则为 `1`，如果抓取失败，则为 `0`。
- `scrape_duration_seconds{job="<job-name>", instance="<instance-id>"}`：抓取的持续时间。
- `scrape_samples_post_metric_relabeling{job="<job-name>", instance="<instance-id>"}`：应用指标重新标记后剩余的样本数。
- `scrape_samples_scraped{job="<job-name>", instance="<instance-id>"}`：目标暴露的样本数。
- `scrape_series_ added{job="<job-name>", instance="<instance-id>"}`：此抓取中新序列的大致数量。 v2.10 中的新功能
正常运行时间序列对于实例可用性监控很有用。



### 查询 
Prometheus 提供了一种称为 PromQL（Prometheus Query Language）的函数式查询语言，可以让用户实时选择和聚合时间序列数据。表达式的结果可以显示为图形，在 Prometheus 的表达式浏览器中查看为表格数据，也可以通过 HTTP API 由外部系统使用。

#### 基础

##### 例子
本文档仅供参考。为了学习，从几个 [例子](https://prometheus.io/docs/prometheus/latest/querying/examples/) 开始可能会更容易。

##### 表达式语言数据类型
在 Prometheus 的表达式语言中，表达式或子表达式可以计算为以下四种类型之一：

- **即时向量(Instant vector)** - 一组时间序列，每个时间序列包含一个样本，所有时间序列都共享相同的时间戳
- **范围向量(Range vector)** - 一组时间序列，包含每个时间序列随时间变化的数据点范围
- **标量(Scalar)** - 一个简单的数字浮点值
- **String** - 一个简单的字符串值；目前未使用
根据用例（例如，在绘制与显示表达式的输出时），作为用户指定表达式的结果，只有其中一些类型是合法的。例如，返回即时向量的表达式是唯一可以直接绘制(graph)的类型。

即，Prometheus 的 graph 只能使用 即时向量(instant vector) 绘制

#### 运算符(OPERATORS)
##### 二元运算符
Prometheus 的查询语言支持基本的逻辑和算术运算符。 对于两个瞬时向量(instant vector)之间的操作，可以修改匹配行为。

###### 算术二元运算符
Prometheus 中存在以下二元算术运算符：
- `+` (加)
- `-` (减)
- `*` (乘)
- `/` (除)
- `%` (求余)
- `^` (幂次方)
二元算术运算符定义在标量/标量、向量/标量和向量/向量值对之间。

在两个标量之间，行为很明显：它们计算另一个标量，该标量是应用于两个标量操作数的运算符的结果。

在即时向量和标量之间，运算符应用于向量中每个数据样本的值。 例如。 如果时间序列瞬时向量乘以 2，则结果是另一个向量，其中原始向量的每个样本值都乘以 2。指标名称被删除。

在两个即时向量之间，对左侧向量中的每个条目及其右侧向量中的匹配元素应用二元算术运算符。 结果传播到结果向量中，分组标签成为输出标签集。 指标名称被删除。 在右侧向量中找不到匹配条目的条目不是结果的一部分。

###### 比较二元运算符
Prometheus 中存在以下二元比较运算符：

- `==`（等于）
- `!=`（不等于）
- `>`（大于）
- `<`（小于）
- `>=`（大于或等于）
- `<=`（小于或等于）
比较运算符在标量/标量、向量/标量和向量/向量值对之间定义。默认情况下，它们会过滤。它们的行为可以通过在运算符之后提供 bool 来修改，它将返回 0 或 1 的值而不是过滤。

在两个标量之间，必须提供 bool 修饰符，这些运算符会产生另一个标量，该标量要么是 0（假）要么是 1（真），这取决于比较结果。

在即时向量和标量之间，这些运算符应用于向量中每个数据样本的值，并且从结果向量中删除其间比较结果为假的向量元素。如果提供了 bool 修饰符，则将被删除的向量元素的值为 0，而将保留的向量元素的值为 1。如果提供了 bool 修饰符，则指标名称将被删除。

在两个即时向量之间，这些运算符默认充当过滤器，应用于匹配条目。表达式不为真或在表达式的另一侧找不到匹配项的向量元素从结果中删除，而其他元素则传播到结果向量中，分组标签成为输出标签集。如果提供了 bool 修饰符，则将被删除的向量元素的值为 0，而将保留的向量元素的值为 1，分组标签再次成为输出标签集。如果提供了 bool 修饰符，则指标名称将被删除。

###### 逻辑/设置二元运算符
这些逻辑/集合二元运算符仅在即时向量之间定义：

- `and` （和）
- `or` （或）
- `unless`（除非）
`vector1 and vector2` 产生一个由 vector1 的元素组成的向量，其中 vector2 中的元素具有完全匹配的标签集。其他元素被丢弃。指标名称和值从左侧向量结转。

`vector1 or vector2` 产生的向量包含 vector1 的所有原始元素（标签集 + 值）以及 vector2 中所有在 vector1 中没有匹配标签集的元素。

`vector1 unless vector2` 产生一个由 vector1 的元素组成的向量，对于这些元素， vector2 中没有具有完全匹配标签集的元素。两个向量中的所有匹配元素都被删除。

##### 向量匹配
向量之间的操作尝试为左侧的每个条目在右侧向量中找到匹配元素。 匹配行为有两种基本类型：一对一和多对一/一对多。
     
###### 一对一向量匹配(One-to-one vector matches)
一对一从操作的每一侧找到一对唯一的条目。 在默认情况下，这是一个遵循 `vector1 <operator> vector2` 格式的操作。 如果两个条目具有完全相同的一组标签和相应的值，则它们匹配。 `ignoring` 关键字允许在匹配时忽略某些标签，而 `on` 关键字允许将考虑的标签集减少到提供的列表：
```
<vector expr> <bin-op> ignoring(<label list>) <vector expr>
<vector expr> <bin-op> on(<label list>) <vector expr>
```
输入示例:
```
method_code:http_errors:rate5m{method="get", code="500"}  24
method_code:http_errors:rate5m{method="get", code="404"}  30
method_code:http_errors:rate5m{method="put", code="501"}  3
method_code:http_errors:rate5m{method="post", code="500"} 6
method_code:http_errors:rate5m{method="post", code="404"} 21

method:http_requests:rate5m{method="get"}  600
method:http_requests:rate5m{method="del"}  34
method:http_requests:rate5m{method="post"} 120
```
查询示例:
```
method_code:http_errors:rate5m{code="500"} / ignoring(code) method:http_requests:rate5m
```
这将返回一个结果向量，其中包含在过去 5 分钟内测量的每种方法的状态代码为 500 的 HTTP 请求的比例。 没有 `ignoring(code)` ，就不会有匹配项，因为指标不共享同一组标签。 带有 `put` 和 `del` 方法的条目没有匹配项，不会显示在结果中：
```
{method="get"}  0.04            //  24 / 600
{method="post"} 0.05            //   6 / 120
```

###### 多对一和一对多向量匹配(Many-to-one and one-to-many vector matches)
多对一和一对多匹配是指“一”端的每个向量元素可以与“多”端的多个元素匹配的情况。这必须使用 `group_left` 或 `group_right` 修饰符明确请求，其中左/右确定哪个向量具有更高的基数。
```
<vector expr> <bin-op> ignoring(<label list>) group_left(<label list>) <vector expr>
<vector expr> <bin-op> ignoring(<label list>) group_right(<label list>) <vector expr>
<vector expr> <bin-op> on(<label list>) group_left(<label list>) <vector expr>
<vector expr> <bin-op> on(<label list>) group_right(<label list>) <vector expr>
```
与组修饰符一起提供的标签列表包含要包含在结果指标中的“一”侧的附加标签。因为 `on` 一个标签只能出现在其中一个列表中。结果向量的每个时间序列都必须是唯一可识别的。

分组修饰符只能用于比较和算术。默认情况下，操作作为和，除非和或操作与正确向量中的所有可能条目匹配。

示例查询：
```
method_code:http_errors:rate5m / ignoring(code) group_left method:http_requests:rate5m
```
在这种情况下，左向量每个方法标签值包含一个以上的条目。因此，我们使用 `group_left` 表示这一点。右侧的元素现在与左侧具有相同方法标签的多个元素匹配：
```
{method="get", code="500"} 0.04 // 24 / 600
{method="get", code="404"} 0.05 // 30 / 600
{method="post", code="500"} 0.05 // 6 / 120
{method="post", code="404"} 0.175 // 21 / 120
```
多对一和一对多匹配是应该仔细考虑的高级用例。通常正确使用 `ignoring(<labels>)` 可以提供所需的结果。



##### 聚合运算符(Aggregation operators)
Prometheus 支持以下内置聚合运算符，可用于聚合单个即时向量的元素，从而生成具有聚合值的更少元素的新向量：

- `sum`（计算维度总和）
- `min`（选择最小尺寸）
- `max`（选择最大尺寸）
- `avg`（计算维度上的平均值）
- `group`（结果向量中的所有值都是 1）
- `stddev`（计算维度上的总体标准偏差）
- `stdvar`（计算维度上的总体标准方差）
- `count`（计算向量中元素的数量）
- `count_values`（计算具有相同值的元素数）
- `bottomk`（样本值的最小 k 个元素）
- `topk`（样本值最大的 k 个元素）
- `quantile`（在维度上计算 φ-分位数 (0 ≤ φ ≤ 1)）
这些运算符既可用于聚合所有标签维度，也可通过包含 `without` 或 `by` 子句来保留不同的维度。这些子句可以在表达式之前或之后使用。
```
<aggr-op> [without|by (<label list>)] ([parameter,] <vector expression>)
```
或
```
<aggr-op>([parameter,] <vector expression>) [without|by (<label list>)]
```
标签列表是一个未加引号的标签列表，其中可能包含一个尾随逗号，即 `(label1, label2)` 和 `(label1, label2,)` 都是有效的语法。

`without` 从结果向量中删除列出的标签，而所有其他标签都保留在输出中。 `by` 执行相反的操作并删除未在 `by` 子句中列出的标签，即使它们的标签值在向量的所有元素之间都相同。

只有 `count_values`、`quantile`、`topk` 和 `bottomk` 需要参数。

`count_values` 为每个唯一样本值输出一个时间序列。每个系列都有一个附加标签。该标签的名称由聚合参数给出，标签值是唯一的样本值。每个时间序列的值是样本值出现的次数。

`topk` 和 `bottomk` 与其他聚合器的不同之处在于，在结果向量中返回输入样本的子集，包括原始标签。 `by` 和 `without` 仅用于对输入向量进行分桶。

`quantile` 计算 φ-quantile，即在聚合维度的 N 个指标值中排名第 φ*N 的值。 φ 作为聚合参数提供。例如， `quantile(0.5, ...)` 计算中位数， `quantile(0.95, ...)` 计算第 95 个百分位数。

例子：

如果指标 `http_requests_total` 具有按`application`、`instance`和`group`标签扇出的时间序列，我们可以通过以下方式计算每个应用程序和组在所有实例上看到的 HTTP 请求总数：

```
sum without (instance) (http_requests_total)
```
这相当于：
```
sum by (application, group) (http_requests_total)
```
如果我们只对我们在所有应用程序中看到的 HTTP 请求总数感兴趣，我们可以简单地编写：
```
sum(http_requests_total)
```
要计算运行每个构建版本的二进制文件的数量，我们可以编写：
```
count_values("version", build_version)
```
要获得所有实例中 5 个最大的 HTTP 请求数，我们可以编写：
```
topk(5, http_requests_total)
```
##### 二元运算符优先级(Binary operator precedence)
下面的列表显示了 Prometheus 中二元运算符的优先级，从高到低。
- ^
- *, /, %
- +, -
- ==, !=, <=, <, >=, >
- and, unless
- or
相同优先级的运算符是左结合的。例如，2 * 3 % 2 等价于 (2 * 3) % 2。但是 ^ 是右结合的，所以 2 ^ 3 ^ 2 等价于 2 ^ (3 ^ 2)。



#### 函数(FUNCTIONS)
一些函数有默认参数，例如 `year(v=vector(time()) instant-vector)`。 这意味着有一个参数 `v` 是一个即时向量，如果没有提供，它将默认为表达式 `vector(time())` 的值。
以下详细列举几个常用的函数

##### rate()
`rate(v range-vector)` 计算范围向量中时间序列的每秒平均增长率。 单调性中断（例如由于目标重新启动导致 counter 重置）会自动调整。 此外，计算外推到时间范围的末端，允许遗漏刮擦或刮擦周期与范围时间段的不完美对齐。

以下示例表达式返回过去 5 分钟内测量的 HTTP 请求每秒速率，范围向量中的每个时间序列：
```
rate(http_requests_total{job="api-server"}[5m])
```
`rate` 应该只与 counter 一起使用。 它最适合用于警报和缓慢移动计数器的图形。

请注意，将 rate() 与聚合运算符（例如 sum()）或随时间聚合的函数（任何以 _over_time 结尾的函数）结合使用时，始终先采用 rate()，然后进行聚合。 否则 rate() 无法在目标重新启动时检测计数器重置。

##### irate()
irate(v range-vector) 计算范围向量中时间序列的每秒即时增加率。这是基于最近两个数据点。单调性中断（例如由于目标重新启动导致计数器重置）会自动调整。

以下示例表达式返回范围向量中每个时间序列的两个最近数据点的 HTTP 请求的每秒速率，该请求最多可回溯 5 分钟：
```
irate(http_requests_total{job="api-server"}[5m])
```
`irate` 只应在绘制易变、快速移动的 counter 时使用。将速率用于警报和缓慢移动的计数器，因为速率的短暂变化可能会重置 `FOR` 子句，并且完全由稀有尖峰组成的图形难以阅读。

请注意，将 `irate()` 与聚合运算符（例如 `sum()`）或随时间聚合的函数（任何以 `_over_time` 结尾的函数）结合使用时，始终先使用 `irate()`，然后进行聚合。否则 `irate()` 无法在目标重新启动时检测 counter 重置。


##### 对比 irate 和 rate 区别
irate和rate都会用于计算某个指标在一定时间间隔内的变化速率。但是它们的计算方法有所不同：irate取的是在指定时间范围内的最近两个数据点来算速率，而rate会取指定时间范围内所有数据点，算出一组速率，然后取平均值作为结果。

所以官网文档说：irate适合快速变化的计数器（counter），而rate适合缓慢变化的计数器（counter）。

根据以上算法我们也可以理解，对于快速变化的计数器，如果使用rate，因为使用了平均值，很容易把峰值削平。除非我们把时间间隔设置得足够小，就能够减弱这种效应。


##### increase()
increase(v range-vector) 计算范围向量中时间序列的增加。单调性中断（例如由于目标重新启动导致计数器重置）会自动调整。外推增加以覆盖范围向量选择器中指定的整个时间范围，因此即使计数器仅以整数增量增加，也可以获得非整数结果。

以下示例表达式返回范围向量中每个时间序列在过去 5 分钟内测量的 HTTP 请求数：
```
increase(http_requests_total{job="api-server"}[5m])
```
`increase` 只应与 counter 一起使用。它是 `rate(v)` 乘以指定时间范围窗口下的秒数的语法糖，主要用于人类可读性。在记录规则中使用速率，以便在每秒的基础上一致地跟踪增加。


##### time()
`time()` 返回自 UTC 时间 1970 年 1 月 1 日以来的秒数。 请注意，这实际上并不返回当前时间，而是要计算表达式的时间。

##### timestamp()
`timestamp(v instant-vector)` 返回给定向量的每个样本的时间戳，作为自 UTC 1970 年 1 月 1 日以来的秒数。

##### minute()
`minute(v=vector(time()) instant-vector)` 返回 UTC 中每个给定时间的分钟数。 返回值从 0 到 59。

##### hour()
`hour(v=vector(time()) instant-vector)` 返回一天中每个给定时间的 UTC 时间。 返回值从 0 到 23。

##### day_of_month()
`day_of_month(v=vector(time()) instant-vector)` 返回每月中每个给定时间的 UTC 日期。 返回值从 1 到 31。

##### day_of_week()
`day_of_week(v=vector(time()) instant-vector)` 以 UTC 形式返回每个给定时间的星期几。 返回值从 0 到 6，其中 0 表示星期日等。

##### days_in_month()
`days_in_month(v=vector(time()) instant-vector)` 返回每个给定时间的 UTC 月份中的天数。 返回值是从 28 到 31。

##### month()
`month(v=vector(time()) instant-vector)` 返回一年中每个给定时间的 UTC 月份。 返回值从 1 到 12，其中 1 表示一月等。

这个功能是在 Prometheus 2.0 中添加的

##### year()
`year(v=vector(time()) instant-vector)` 返回 UTC 中每个给定时间的年份。

##### <aggregation>_over_time()
以下函数允许随时间聚合给定范围向量的每个系列，并返回具有每个系列聚合结果的即时向量：
- `avg_over_time(range-vector)`：指定区间内所有点的平均值。
- `min_over_time(range-vector)`：指定区间内所有点的最小值。
- `max_over_time(range-vector)`：指定区间内所有点的最大值。
- `sum_over_time(range-vector)`：指定区间内所有值的总和。
- `count_over_time(range-vector)`：指定区间内所有值的计数。
- `quantile_over_time(scalar, range-vector)`：指定区间内值的 φ-分位数 (0 ≤ φ ≤ 1)。
- `stddev_over_time(range-vector)`：指定区间内值的总体标准差。
- `stdvar_over_time(range-vector)`：指定区间内值的总体标准方差。
- `last_over_time(range-vector)`：指定间隔内的最近点值。
请注意，指定间隔中的所有值在聚合中都具有相同的权重，即使这些值在整个间隔中的间隔不等。

## Alertmanager

- GitHub: [alertmanager](https://github.com/prometheus/alertmanager)
- 官网: [alertmanager](https://prometheus.io/docs/alerting/latest/overview/)

Alertmanager 处理客户端应用程序（例如 Prometheus 服务器）发送的警报。它负责对它们进行重复数据删除、分组和路由到正确的接收器集成，例如 email、PagerDuty 或 OpsGenie。它还负责警报的静默(silence)和抑制(inhibition)。

下面介绍 Alertmanager 实现的核心概念。

### 分组(Group)
分组将类似性质的警报分类为单个通知。当许多系统同时发生故障并且可能同时触发数百到数千个警报时，这在较大的中断期间尤其有用。

示例：当发生网络分区时，集群中正在运行数十个或数百个服务实例。您的一半服务实例无法再访问数据库。 Prometheus 中的警报规则配置为在每个服务实例无法与数据库通信时发送警报。因此，数百个警报被发送到 Alertmanager。

作为用户，您只想获得一个页面，同时仍然能够准确查看哪些服务实例受到影响。因此，可以将 Alertmanager 配置为按集群和警报名称对警报进行分组，以便它发送单个紧凑通知。

警报分组、分组通知的时间以及这些通知的接收者由配置文件中的路由树进行配置。

### 抑制(Inhibition)
抑制是一个概念，如果某些其他警报已经触发，则抑制某些警报的通知。

示例：发出警报，通知无法访问整个集群。如果该特定警报正在触发，Alertmanager 可以配置为静音与该集群相关的所有其他警报。这可以防止收到与实际问题无关的数百或数千个触发警报的通知。

禁止通过 Alertmanager 的配置文件进行配置。

### 静默(Silence)
静默(silence)是在给定时间内简单地将警报静音的直接方法。静默(silence)是基于匹配器配置的，就像路由树一样。检查传入警报是否与活动静默(silence)的所有相等或正则表达式匹配器匹配。如果他们这样做，则不会发送该警报的通知。

静默(silence)是在 Alertmanager 的 Web 界面中配置的。

### 客户行为
Alertmanager 对其客户端的行为有特殊要求。这些仅与不使用 Prometheus 发送警报的高级用例相关。

### 高可用性
Alertmanager 支持配置以创建集群以实现高可用性。这可以使用 --cluster-* 标志进行配置。

重要的是不要在 Prometheus 及其警报管理器之间负载平衡流量，而是将 Prometheus 指向所有警报管理器的列表。 

