# Python 基础语法参考手册

---

## 数据类型

Python 内置基本数据类型一览：

| 类型 | 关键字 | 示例 | 说明 |
|------|--------|------|------|
| 整数 | `int` | `42`, `-7`, `0b1010` | 任意精度，无溢出 |
| 浮点数 | `float` | `3.14`, `1e-3`, `float('inf')` | 双精度64位 |
| 字符串 | `str` | `'hello'`, `"world"`, `"""多行"""` | 不可变，Unicode |
| 布尔值 | `bool` | `True`, `False` | `int` 的子类，True=1, False=0 |
| 空值 | `NoneType` | `None` | 表示"没有值" |

### 类型判断与转换

```python
# 类型判断
type(42)           # <class 'int'>
isinstance(42, int)  # True
isinstance(True, int)  # True（bool 是 int 子类）

# 类型转换
int("42")          # 42
int(3.9)           # 3（截断，非四舍五入）
float("3.14")      # 3.14
str(42)            # "42"
bool(0)            # False
bool("")           # False
bool([])           # False
bool(None)         # False
bool("hello")      # True（非零/非空即为 True）
```

### 数值特殊操作

```python
# 整除与取余
7 // 2    # 3（地板除）
7 % 2     # 1（取模）
divmod(7, 2)  # (3, 1)

# 幂运算
2 ** 10   # 1024
pow(2, 10)    # 1024
pow(2, 10, 100)  # 24（2^10 % 100，高效模幂）

# 进制转换
bin(10)   # '0b1010'
oct(10)   # '0o12'
hex(255)  # '0xff'
int('0xff', 16)  # 255

# 数值边界
import sys
sys.maxsize       # 平台最大整数
float('inf')      # 正无穷
float('-inf')     # 负无穷
float('nan')      # NaN（NaN != NaN）
```

---

## 字符串操作

### 创建与基本操作

```python
s = 'hello world'
s = "hello world"
s = """多行字符串
第二行
第三行"""

# 原始字符串（不转义）
path = r'C:\Users\new folder'  # C:\Users\new folder

# 字节串
b = b'hello'   # bytes 类型
```

### 索引与切片

```python
s = "Hello, Python!"

# 索引（从0开始，支持负数）
s[0]     # 'H'
s[-1]    # '!'
s[-2]    # 'n'

# 切片 [start:stop:step]
s[0:5]   # 'Hello'
s[7:]    # 'Python!'
s[:5]    # 'Hello'
s[::2]   # 'Hlo yhn'（每隔一个字符）
s[::-1]  # '!nohtyP ,olleH'（反转）
```

### 格式化

```python
name = "陈"
age = 30

# f-string（推荐，Python 3.6+）
f"我叫{name}，今年{age}岁"           # '我叫陈，今年30岁'
f"明年{age + 1}岁"                    # '明年31岁'
f"{3.14159:.2f}"                      # '3.14'
f"{42:05d}"                           # '00042'
f"{'hello':>10}"                      # '     hello'（右对齐）
f"{'hello':<10}"                      # 'hello     '（左对齐）
f"{'hello':^10}"                      # '  hello   '（居中）

# str.format()
"我叫{}，今年{}岁".format(name, age)
"我叫{0}，今年{1}岁".format(name, age)
"我叫{n}，今年{a}岁".format(n=name, a=age)

# % 格式化（旧式）
"我叫%s，今年%d岁" % (name, age)
```

### 常用方法

```python
s = "  Hello, Python!  "

# 查找
s.find('Python')     # 9（返回索引，未找到返回 -1）
s.index('Python')    # 9（未找到抛出 ValueError）
s.count('l')         # 2
s.startswith('  H')  # True
s.endswith('!  ')    # True

# 变换
s.strip()            # 'Hello, Python!'（去两端空白）
s.lstrip()           # 'Hello, Python!  '
s.rstrip()           # '  Hello, Python!'
s.lower()            # '  hello, python!  '
s.upper()            # '  HELLO, PYTHON!  '
s.title()            # '  Hello, Python!  '
s.capitalize()       # '  hello, python!  '
s.swapcase()         # '  hELLO, pYTHON!  '
s.replace('Python', 'World')  # '  Hello, World!  '

# 拆分与合并
"a,b,c".split(',')           # ['a', 'b', 'c']
"a  b  c".split()            # ['a', 'b', 'c']（默认按空白分割）
"hello".split('l')           # ['he', '', 'o']
','.join(['a', 'b', 'c'])   # 'a,b,c'

# 判断
"123".isdigit()      # True
"abc".isalpha()      # True
"abc123".isalnum()   # True
"   ".isspace()      # True
"Hello".isupper()    # False
"HELLO".isupper()    # True

# 居中/对齐
"hello".center(11, '-')   # '---hello---'
"hello".ljust(10, '.')    # 'hello.....'
"hello".rjust(10, '.')    # '.....hello'
```

---

## 运算符

### 算术运算符

| 运算符 | 描述 | 示例 | 结果 |
|--------|------|------|------|
| `+` | 加 | `3 + 2` | `5` |
| `-` | 减 | `3 - 2` | `1` |
| `*` | 乘 | `3 * 2` | `6` |
| `/` | 除（真除法） | `7 / 2` | `3.5` |
| `//` | 地板除 | `7 // 2` | `3` |
| `%` | 取模 | `7 % 2` | `1` |
| `**` | 幂 | `2 ** 3` | `8` |

### 比较运算符

| 运算符 | 描述 | 示例 | 结果 |
|--------|------|------|------|
| `==` | 等于 | `1 == 1` | `True` |
| `!=` | 不等于 | `1 != 2` | `True` |
| `>` | 大于 | `2 > 1` | `True` |
| `<` | 小于 | `1 < 2` | `True` |
| `>=` | 大于等于 | `2 >= 2` | `True` |
| `<=` | 小于等于 | `1 <= 2` | `True` |
| `is` | 身份判断（同一对象） | `a is None` | - |
| `is not` | 非同一对象 | `a is not None` | - |

```python
# 注意 is 与 == 的区别
a = [1, 2, 3]
b = [1, 2, 3]
a == b      # True（值相等）
a is b      # False（不是同一对象）

# None 判断用 is
x = None
x is None   # True（推荐）
x == None   # True（不推荐）
```

### 逻辑运算符

```python
True and False   # False
True or False    # True
not True         # False

# 短路求值
1 and 2      # 2（1为真，返回后面的值）
0 and 2      # 0（0为假，短路返回0）
1 or 2       # 1（1为真，短路返回1）
0 or 2       # 2（0为假，返回后面的值）
0 or ""      # ''（都为假，返回最后一个假值）

# 实用技巧
name = input_name or "匿名"   # 默认值
```

### 位运算符

```python
5 & 3    # 1   (0b101 & 0b011 = 0b001)  按位与
5 | 3    # 7   (0b101 | 0b011 = 0b111)  按位或
5 ^ 3    # 6   (0b101 ^ 0b011 = 0b110)  按位异或
~5       # -6  按位取反
5 << 1   # 10  左移一位（×2）
5 >> 1   # 2   右移一位（÷2）
```

### 赋值运算符

```python
# 基本赋值
x = 10

# 增强赋值
x += 5    # x = x + 5 → 15
x -= 3    # x = x - 3 → 12
x *= 2    # x = x * 2 → 24
x //= 3   # x = x // 3 → 8
x %= 3    # x = x % 3 → 2
x **= 3   # x = x ** 3 → 8

# 多重赋值
a, b, c = 1, 2, 3
a = b = c = 0

# 交换变量
a, b = b, a

# 海象运算符（Python 3.8+）
if (n := len(data)) > 10:
    print(f"数据量{n}，超过10")
```

---

## 列表

### 创建

```python
# 直接创建
nums = [1, 2, 3, 4, 5]
mixed = [1, "hello", 3.14, True]
nested = [[1, 2], [3, 4]]

# 从其他对象创建
list("abc")         # ['a', 'b', 'c']
list(range(5))      # [0, 1, 2, 3, 4]

# 重复与拼接
[0] * 5             # [0, 0, 0, 0, 0]
[1, 2] + [3, 4]    # [1, 2, 3, 4]
```

### 索引与切片

```python
lst = [10, 20, 30, 40, 50]

lst[0]      # 10
lst[-1]     # 50
lst[1:3]    # [20, 30]
lst[::-1]   # [50, 40, 30, 20, 10]

# 切片赋值
lst[1:3] = [200, 300]  # [10, 200, 300, 40, 50]
```

### 常用操作

```python
lst = [3, 1, 4, 1, 5]

# 增
lst.append(9)          # 末尾添加 → [3, 1, 4, 1, 5, 9]
lst.insert(0, 0)       # 指定位置插入
lst.extend([2, 6])     # 扩展列表

# 删
lst.pop()              # 弹出末尾元素
lst.pop(0)             # 弹出指定索引
lst.remove(1)          # 删除第一个值为1的元素
del lst[2]             # 按索引删除

# 改
lst[0] = 100           # 直接赋值

# 查
lst.index(4)           # 返回第一个4的索引
lst.count(1)           # 统计1出现的次数
9 in lst               # True

# 排序
lst.sort()             # 原地排序（升序）
lst.sort(reverse=True) # 原地排序（降序）
lst.sort(key=lambda x: -x)  # 自定义排序

sorted_lst = sorted(lst)        # 返回新列表
sorted_lst = sorted(lst, reverse=True)

# 反转
lst.reverse()          # 原地反转
reversed_lst = lst[::-1]  # 返回新列表

# 其他
len(lst)               # 长度
min(lst)               # 最小值
max(lst)               # 最大值
sum(lst)               # 求和

# 复制
new_lst = lst.copy()   # 浅拷贝
new_lst = lst[:]       # 浅拷贝
import copy
new_lst = copy.deepcopy(lst)  # 深拷贝
```

---

## 元组

```python
# 创建
t = (1, 2, 3)
t = 1, 2, 3           # 省略括号
t = (1,)               # 单元素元组（注意逗号）
t = ()                 # 空元组
t = tuple([1, 2, 3])   # 从列表创建
t = tuple("abc")       # ('a', 'b', 'c')

# 访问（与列表相同）
t[0]       # 1
t[1:]      # (2, 3)
t[-1]      # 3

# 不可变！以下操作会报错
# t[0] = 10  # TypeError

# 解包
a, b, c = t
a, *rest = t           # a=1, rest=[2, 3]
a, *_, c = t           # a=1, c=3（忽略中间）

# 命名元组
from collections import namedtuple
Point = namedtuple('Point', ['x', 'y'])
p = Point(3, 4)
p.x       # 3
p.y       # 4
p[0]      # 3（仍然可以索引）

# 元组作为字典键（因为不可变）
d = {(1, 2): "value"}  # 合法
# d = {[1, 2]: "value"}  # TypeError（列表不可哈希）
```

---

## 字典

### 创建

```python
# 直接创建
d = {"name": "陈", "age": 30}
d = {}                  # 空字典
d = dict(name="陈", age=30)
d = dict([("name", "陈"), ("age", 30)])
d = dict.fromkeys(['a', 'b', 'c'], 0)  # {'a': 0, 'b': 0, 'c': 0}

# Python 3.7+ 字典保持插入顺序
```

### 访问与操作

```python
d = {"name": "陈", "age": 30, "city": "广州"}

# 访问
d["name"]              # '陈'
d.get("name")          # '陈'
d.get("phone", "无")   # '无'（键不存在返回默认值）

# 修改/添加
d["age"] = 31          # 修改
d["phone"] = "138xxxx" # 新增

# 安全获取并设置默认值
d.setdefault("email", "unknown")  # 不存在则添加并返回
d.setdefault("name", "default")   # 已存在则返回原值

# 删除
del d["city"]          # 删除键
d.pop("phone")         # 弹出并返回值
d.pop("missing", None) # 键不存在返回默认值

# 更新
d.update({"age": 32, "gender": "M"})  # 合并更新
d.update(email="test@test.com")

# 遍历
for key in d:                    # 遍历键
for key in d.keys():             # 遍历键
for value in d.values():         # 遍历值
for key, value in d.items():     # 遍历键值对

# 检查
"name" in d             # True
len(d)                  # 3

# 合并字典（Python 3.9+）
d1 = {"a": 1, "b": 2}
d2 = {"b": 3, "c": 4}
merged = d1 | d2        # {'a': 1, 'b': 3, 'c': 4}（后者覆盖）
d1 |= d2                # 原地合并

# Python 3.5+ 合并
merged = {**d1, **d2}   # 效果同上
```

---

## 集合

```python
# 创建
s = {1, 2, 3}
s = set([1, 2, 2, 3])   # {1, 2, 3}（自动去重）
s = set("hello")         # {'h', 'e', 'l', 'o'}
s = set()                # 空集合（注意：{} 是空字典！）

# 添加与删除
s.add(4)                 # 添加元素
s.discard(4)             # 删除（不存在不报错）
s.remove(4)              # 删除（不存在抛出 KeyError）
s.pop()                  # 随机弹出一个元素
s.clear()                # 清空

# 集合运算
a = {1, 2, 3, 4}
b = {3, 4, 5, 6}

a | b       # {1, 2, 3, 4, 5, 6}  并集
a & b       # {3, 4}              交集
a - b       # {1, 2}              差集（a有b没有）
a ^ b       # {1, 2, 5, 6}        对称差集（不同时在两个集合）

a.union(b)          # 并集（返回新集合）
a.intersection(b)   # 交集
a.difference(b)     # 差集
a.symmetric_difference(b)  # 对称差集

# 子集与超集
{1, 2} <= {1, 2, 3}      # True（子集）
{1, 2}.issubset({1, 2, 3})  # True
{1, 2, 3} >= {1, 2}      # True（超集）

# 去重实用
names = ["张三", "李四", "张三", "王五"]
unique = list(set(names))  # 去重（顺序不保证）
# 保持顺序去重
unique = list(dict.fromkeys(names))  # Python 3.7+ 保持顺序
```

---

## 条件语句

```python
# 基本 if
score = 85
if score >= 90:
    grade = "优秀"
elif score >= 80:
    grade = "良好"
elif score >= 60:
    grade = "及格"
else:
    grade = "不及格"

# 三元表达式
grade = "及格" if score >= 60 else "不及格"

# 多条件判断
x = 15
if 10 < x < 20:        # Python 支持链式比较
    print("在范围内")

# match-case（Python 3.10+）
command = "quit"
match command:
    case "start":
        print("启动")
    case "stop":
        print("停止")
    case "quit" | "exit":   # 或模式
        print("退出")
    case _:
        print("未知命令")

# match-case 解构
point = (3, 4)
match point:
    case (0, 0):
        print("原点")
    case (x, 0):
        print(f"x轴上，x={x}")
    case (0, y):
        print(f"y轴上，y={y}")
    case (x, y):
        print(f"坐标({x}, {y})")
```

---

## 循环

### for 循环

```python
# 遍历列表
fruits = ["苹果", "香蕉", "橙子"]
for fruit in fruits:
    print(fruit)

# 遍历字典
d = {"name": "陈", "age": 30}
for key, value in d.items():
    print(f"{key}: {value}")

# range
for i in range(5):        # 0, 1, 2, 3, 4
    print(i)
for i in range(2, 10, 3): # 2, 5, 8
    print(i)

# enumerate（带索引遍历）
for index, fruit in enumerate(fruits):
    print(f"{index}: {fruit}")
for index, fruit in enumerate(fruits, start=1):
    print(f"{index}: {fruit}")  # 从1开始编号

# zip（并行遍历）
names = ["Alice", "Bob", "Charlie"]
ages = [25, 30, 35]
for name, age in zip(names, ages):
    print(f"{name}: {age}")
# zip 不等长时以最短的为准
# zip_longest 在 itertools 中，以最长的为准

# 反向遍历
for fruit in reversed(fruits):
    print(fruit)

# 排序遍历
for fruit in sorted(fruits):
    print(fruit)
```

### while 循环

```python
count = 0
while count < 5:
    print(count)
    count += 1

# while-else（循环正常结束执行 else）
n = 10
i = 2
while i < n:
    if n % i == 0:
        print(f"{n} 不是质数")
        break
    i += 1
else:
    print(f"{n} 是质数")  # 循环未被 break 才执行

# for-else 同理
for i in range(2, n):
    if n % i == 0:
        print(f"{n} 不是质数")
        break
else:
    print(f"{n} 是质数")
```

### break / continue / pass

```python
# break：跳出整个循环
for i in range(10):
    if i == 5:
        break
    print(i)  # 输出 0,1,2,3,4

# continue：跳过本次迭代
for i in range(10):
    if i % 2 == 0:
        continue
    print(i)  # 输出 1,3,5,7,9

# pass：占位，什么都不做
class MyError(Exception):
    pass  # 待实现

def todo():
    pass  # 待实现
```

---

## 函数

### 定义与调用

```python
def greet(name, greeting="你好"):
    """打招呼函数
    
    Args:
        name: 名字
        greeting: 问候语，默认"你好"
    
    Returns:
        问候字符串
    """
    return f"{greeting}，{name}！"

greet("陈")            # '你好，陈！'
greet("陈", "Hello")   # 'Hello，陈！'
greet(name="陈", greeting="Hi")  # 关键字参数
```

### 参数类型

```python
# 位置参数
def add(a, b):
    return a + b

# 默认参数（默认参数必须放在后面）
def power(base, exp=2):
    return base ** exp

# 可变位置参数 *args
def sum_all(*args):
    return sum(args)

sum_all(1, 2, 3)    # 6
sum_all(1, 2, 3, 4) # 10

# 可变关键字参数 **kwargs
def print_info(**kwargs):
    for key, value in kwargs.items():
        print(f"{key} = {value}")

print_info(name="陈", age=30)

# 混合使用（顺序：位置 → *args → 关键字 → **kwargs）
def func(a, b, *args, key="default", **kwargs):
    pass

# 仅关键字参数（Python 3+）
def f(a, b, *, key):  # key 必须用关键字传入
    pass
f(1, 2, key=3)  # OK
# f(1, 2, 3)    # TypeError

# 仅位置参数（Python 3.8+）
def f(a, b, /, c):   # a, b 只能位置传，c 两种都行
    pass
f(1, 2, 3)     # OK
f(1, 2, c=3)   # OK
# f(a=1, b=2, c=3)  # TypeError
```

### 返回值

```python
# 单返回值
def square(x):
    return x * x

# 多返回值（返回元组）
def min_max(lst):
    return min(lst), max(lst)

lo, hi = min_max([3, 1, 4, 1, 5])  # lo=1, hi=5

# 无 return 则返回 None
def say_hello():
    print("Hello")
```

### 作用域

```python
x = "全局"

def outer():
    x = "外部"
    
    def inner():
        nonlocal x   # 引用外层函数的 x
        x = "内部"
    
    inner()
    print(x)  # "内部"

def modify_global():
    global x   # 引用全局 x
    x = "修改后的全局"

# LEGB 规则：Local → Enclosing → Global → Built-in
```

### 闭包与高阶函数

```python
# 闭包
def make_counter(start=0):
    count = start
    def counter():
        nonlocal count
        count += 1
        return count
    return counter

c = make_counter()
c()  # 1
c()  # 2
c()  # 3

c2 = make_counter(10)
c2()  # 11

# 高阶函数（函数作为参数或返回值）
def apply(func, value):
    return func(value)

apply(lambda x: x ** 2, 5)  # 25
```

---

## 高级函数

### lambda 表达式

```python
# 匿名函数
square = lambda x: x ** 2
square(5)  # 25

add = lambda a, b: a + b
add(3, 4)  # 7

# 常见用途：排序、过滤
students = [("陈", 85), ("李", 92), ("王", 78)]
students.sort(key=lambda s: s[1], reverse=True)  # 按分数降序

# 条件 lambda
max_val = lambda a, b: a if a > b else b
```

### map / filter / reduce

```python
# map：映射
list(map(str, [1, 2, 3]))           # ['1', '2', '3']
list(map(lambda x: x ** 2, [1, 2, 3]))  # [1, 4, 9]
list(map(lambda x, y: x + y, [1, 2], [3, 4]))  # [4, 6]

# filter：过滤
list(filter(lambda x: x > 3, [1, 2, 3, 4, 5]))  # [4, 5]

# reduce：累积（需导入）
from functools import reduce
reduce(lambda acc, x: acc + x, [1, 2, 3, 4])  # 10
reduce(lambda acc, x: acc * x, [1, 2, 3, 4], 1)  # 24（带初始值）
```

---

## 装饰器

```python
# 基本装饰器
def timer(func):
    import time
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        end = time.time()
        print(f"{func.__name__} 耗时 {end - start:.4f}s")
        return result
    return wrapper

@timer
def slow_function():
    import time
    time.sleep(1)

slow_function()  # slow_function 耗时 1.0012s

# 带参数的装饰器
def retry(max_attempts=3):
    def decorator(func):
        def wrapper(*args, **kwargs):
            for attempt in range(max_attempts):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    if attempt == max_attempts - 1:
                        raise
                    print(f"第{attempt + 1}次失败，重试...")
        return wrapper
    return decorator

@retry(max_attempts=5)
def unstable_request():
    pass

# functools.wraps（保留原函数元信息）
from functools import wraps

def my_decorator(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        """wrapper的文档"""
        return func(*args, **kwargs)
    return wrapper

@my_decorator
def my_func():
    """my_func的文档"""
    pass

my_func.__name__   # 'my_func'（而不是 'wrapper'）
my_func.__doc__    # 'my_func的文档'
```

---

## 生成器与迭代器

### 迭代器

```python
# 迭代器协议：__iter__() + __next__()
lst = [1, 2, 3]
it = iter(lst)      # 获取迭代器
next(it)            # 1
next(it)            # 2
next(it)            # 3
# next(it)          # StopIteration

# 自定义迭代器
class Countdown:
    def __init__(self, start):
        self.current = start
    
    def __iter__(self):
        return self
    
    def __next__(self):
        if self.current <= 0:
            raise StopIteration
        self.current -= 1
        return self.current + 1

for n in Countdown(3):
    print(n)  # 3, 2, 1
```

### 生成器

```python
# 生成器函数（使用 yield）
def fibonacci(n):
    a, b = 0, 1
    for _ in range(n):
        yield a
        a, b = b, a + b

list(fibonacci(10))  # [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]

# 生成器是惰性求值，节省内存
gen = fibonacci(1000000)  # 不会立刻计算，逐个产出

# yield from（委托给子生成器）
def chain(*iterables):
    for it in iterables:
        yield from it

list(chain([1, 2], [3, 4], [5]))  # [1, 2, 3, 4, 5]

# 生成器表达式
squares = (x ** 2 for x in range(10))
list(squares)  # [0, 1, 4, 9, 16, 25, 36, 49, 64, 81]

# 对比：列表推导式立即求值，生成器表达式惰性求值
import sys
lst_comp = [x ** 2 for x in range(10000)]
gen_exp = (x ** 2 for x in range(10000))
sys.getsizeof(lst_comp)  # ~87616 bytes
sys.getsizeof(gen_exp)   # ~200 bytes
```

---

## 面向对象

### 类的定义

```python
class Person:
    # 类属性（所有实例共享）
    species = "人类"
    
    # 初始化方法
    def __init__(self, name, age):
        # 实例属性
        self.name = name
        self.age = age
        self._protected = "受保护"   # 约定：单下划线，内部使用
        self.__private = "私有"      # 名称修饰：_Person__private
    
    # 实例方法
    def introduce(self):
        return f"我叫{self.name}，今年{self.age}岁"
    
    # 类方法
    @classmethod
    def from_birth_year(cls, name, birth_year):
        age = 2025 - birth_year
        return cls(name, age)
    
    # 静态方法
    @staticmethod
    def is_adult(age):
        return age >= 18

# 使用
p = Person("陈", 30)
p.introduce()                    # '我叫陈，今年30岁'
Person.species                   # '人类'

p2 = Person.from_birth_year("李", 1995)
p2.age                           # 30

Person.is_adult(20)              # True
```

### 继承

```python
class Animal:
    def __init__(self, name):
        self.name = name
    
    def speak(self):
        raise NotImplementedError("子类必须实现 speak")

class Dog(Animal):
    def __init__(self, name, breed):
        super().__init__(name)   # 调用父类初始化
        self.breed = breed
    
    def speak(self):
        return f"{self.name}：汪汪！"

class Cat(Animal):
    def speak(self):
        return f"{self.name}：喵喵~"

# 多态
animals = [Dog("旺财", "柯基"), Cat("小花")]
for animal in animals:
    print(animal.speak())  # 旺财：汪汪！  小花：喵喵~

# isinstance 与 issubclass
isinstance(Dog("旺财", "柯基"), Animal)  # True
issubclass(Dog, Animal)                   # True

# 多继承与 MRO
class A:
    def greet(self):
        return "A"

class B(A):
    def greet(self):
        return "B"

class C(A):
    def greet(self):
        return "C"

class D(B, C):
    pass

D().greet()          # "B"（MRO: D → B → C → A）
D.__mro__            # 查看方法解析顺序
```

### 封装与属性

```python
class Circle:
    def __init__(self, radius):
        self._radius = radius
    
    # getter
    @property
    def radius(self):
        return self._radius
    
    # setter
    @radius.setter
    def radius(self, value):
        if value <= 0:
            raise ValueError("半径必须为正数")
        self._radius = value
    
    # 只读属性
    @property
    def area(self):
        import math
        return math.pi * self._radius ** 2

c = Circle(5)
c.radius      # 5
c.area        # 78.5398...
c.radius = 10 # OK
# c.radius = -1  # ValueError

# __slots__（限制属性，节省内存）
class Point:
    __slots__ = ('x', 'y')
    def __init__(self, x, y):
        self.x = x
        self.y = y

p = Point(1, 2)
# p.z = 3  # AttributeError
```

---

## 魔术方法

```python
class Vector:
    def __init__(self, x, y):
        self.x = x
        self.y = y
    
    # 字符串表示
    def __str__(self):          # print() / str() 调用
        return f"Vector({self.x}, {self.y})"
    
    def __repr__(self):         # 交互式 / repr() 调用
        return f"Vector({self.x!r}, {self.y!r})"
    
    # 运算符重载
    def __add__(self, other):
        return Vector(self.x + other.x, self.y + other.y)
    
    def __sub__(self, other):
        return Vector(self.x - other.x, self.y - other.y)
    
    def __mul__(self, scalar):
        return Vector(self.x * scalar, self.y * scalar)
    
    def __eq__(self, other):
        return self.x == other.x and self.y == other.y
    
    def __lt__(self, other):
        return self.length() < other.length()
    
    # 其他常用
    def __len__(self):
        return 2
    
    def __getitem__(self, index):
        return (self.x, self.y)[index]
    
    def __iter__(self):
        yield self.x
        yield self.y
    
    def __bool__(self):
        return self.x != 0 or self.y != 0
    
    def __hash__(self):
        return hash((self.x, self.y))
    
    # 辅助
    def length(self):
        return (self.x ** 2 + self.y ** 2) ** 0.5

v1 = Vector(3, 4)
v2 = Vector(1, 2)

print(v1)             # Vector(3, 4)
v1 + v2               # Vector(4, 6)
v1 * 2                # Vector(6, 8)
v1 == v2              # False
v1 < v2               # False
len(v1)               # 2
list(v1)              # [3, 4]
bool(Vector(0, 0))    # False
```

### 常用魔术方法速查

| 分类 | 方法 | 触发方式 |
|------|------|---------|
| 构造/销毁 | `__init__`, `__del__`, `__new__` | 创建/销毁实例 |
| 字符串 | `__str__`, `__repr__`, `__format__` | str()/repr()/format() |
| 比较 | `__eq__`, `__ne__`, `__lt__`, `__le__`, `__gt__`, `__ge__` | ==, !=, <, <=, >, >= |
| 算术 | `__add__`, `__sub__`, `__mul__`, `__truediv__`, `__floordiv__`, `__mod__`, `__pow__` | +, -, *, /, //, %, ** |
| 反算术 | `__radd__`, `__rsub__`, `__rmul__` | 右侧运算 |
| 增量赋值 | `__iadd__`, `__isub__`, `__imul__` | +=, -=, *= |
| 容器 | `__len__`, `__getitem__`, `__setitem__`, `__delitem__`, `__contains__` | len(), [], in |
| 迭代 | `__iter__`, `__next__` | for/in循环 |
| 上下文 | `__enter__`, `__exit__` | with语句 |
| 可调用 | `__call__` | 把实例当函数调用 |

---

## 模块与包

```python
# 导入方式
import os                       # 导入整个模块
import os.path                  # 导入子模块
from os import path             # 导入特定对象
from os.path import join        # 导入特定函数
from os import path as osp      # 起别名
from os.path import join as j   # 函数起别名

# 相对导入（包内部使用）
from . import module            # 当前包
from .. import module           # 上级包
from .module import func        # 当前包的模块

# __name__ 判断
if __name__ == "__main__":
    # 仅在直接运行时执行，被导入时不执行
    main()

# __all__ 控制 from module import * 的导出范围
__all__ = ["func1", "Class1", "CONST"]

# 查看模块信息
dir(os)             # 查看所有属性
help(os.path.join)  # 查看帮助文档
os.__file__         # 模块文件路径

# 包结构
"""
mypackage/
├── __init__.py     # 包初始化（Python 3.3+ 可省略，但建议保留）
├── module_a.py
├── module_b.py
└── subpackage/
    ├── __init__.py
    └── module_c.py
"""
```

---

## 文件IO

### 读写文本文件

```python
# 读取整个文件
with open("data.txt", "r", encoding="utf-8") as f:
    content = f.read()          # 读取全部

# 逐行读取
with open("data.txt", "r", encoding="utf-8") as f:
    for line in f:              # 内存友好
        print(line.strip())

# 读取所有行
with open("data.txt", "r", encoding="utf-8") as f:
    lines = f.readlines()       # 返回列表

# 写入文件
with open("output.txt", "w", encoding="utf-8") as f:
    f.write("第一行\n")
    f.writelines(["第二行\n", "第三行\n"])

# 追加
with open("output.txt", "a", encoding="utf-8") as f:
    f.write("追加的内容\n")

# 读写模式
```

### 模式速查

| 模式 | 描述 | 文件不存在 | 文件存在 |
|------|------|-----------|---------|
| `r` | 只读 | 报错 | 从头读 |
| `w` | 只写 | 创建 | 覆盖 |
| `a` | 追加 | 创建 | 末尾追加 |
| `r+` | 读写 | 报错 | 从头读写 |
| `w+` | 写读 | 创建 | 覆盖 |
| `a+` | 追加读写 | 创建 | 末尾追加 |
| `rb`/`wb` | 二进制模式 | - | - |

### 路径操作（pathlib 推荐）

```python
from pathlib import Path

# 创建路径对象
p = Path("/Users/ms.chen/Documents")
p = Path("data") / "files" / "test.txt"  # 路径拼接

# 路径信息
p.name       # 'test.txt'（文件名）
p.stem       # 'test'（不含后缀）
p.suffix     # '.txt'（后缀）
p.parent     # 父目录 Path 对象
p.exists()   # 是否存在
p.is_file()  # 是否是文件
p.is_dir()   # 是否是目录

# 文件操作
p.mkdir(parents=True, exist_ok=True)  # 创建目录
p.touch()            # 创建空文件
p.rename("new.txt")  # 重命名
p.unlink()           # 删除文件
p.rmdir()            # 删除空目录

# 遍历
list(p.parent.iterdir())          # 列出目录内容
list(p.parent.glob("*.txt"))      # 通配符匹配
list(p.parent.rglob("*.py"))      # 递归匹配

# 读写的快捷方式（Python 3.5+）
Path("data.txt").read_text(encoding="utf-8")
Path("data.txt").write_text("内容", encoding="utf-8")
```

---

## 异常处理

```python
# 基本 try-except
try:
    result = 10 / 0
except ZeroDivisionError:
    print("除零错误")

# 捕获多种异常
try:
    f = open("not_exist.txt")
except (FileNotFoundError, PermissionError) as e:
    print(f"文件错误: {e}")

# try-except-else-finally
try:
    f = open("data.txt", "r")
except FileNotFoundError:
    print("文件不存在")
else:
    # 没有异常时执行
    content = f.read()
    f.close()
finally:
    # 无论如何都执行
    print("清理完成")

# 抛出异常
def set_age(age):
    if age < 0:
        raise ValueError("年龄不能为负数")
    return age

# 自定义异常
class AppError(Exception):
    """应用基础异常"""
    pass

class NotFoundError(AppError):
    """资源未找到"""
    def __init__(self, resource, resource_id):
        self.resource = resource
        self.resource_id = resource_id
        super().__init__(f"{resource} (id={resource_id}) 未找到")

raise NotFoundError("用户", 42)

# 异常链
try:
    json.loads("invalid")
except json.JSONDecodeError as e:
    raise ValueError("配置解析失败") from e

# assert 断言
assert age >= 0, "年龄不能为负数"  # 等价于 if not condition: raise AssertionError

# 常见内置异常
"""
BaseException
├── SystemExit
├── KeyboardInterrupt
├── GeneratorExit
└── Exception
    ├── StopIteration
    ├── ArithmeticError
    │   ├── ZeroDivisionError
    │   └── OverflowError
    ├── LookupError
    │   ├── IndexError
    │   └── KeyError
    ├── OSError
    │   ├── FileNotFoundError
    │   ├── PermissionError
    │   └── IsADirectoryError
    ├── TypeError
    ├── ValueError
    ├── AttributeError
    ├── ImportError
    │   └── ModuleNotFoundError
    ├── RuntimeError
    │   └── RecursionError
    └── NameError
"""
```

---

## 常用内置函数

| 函数 | 说明 | 示例 | 结果 |
|------|------|------|------|
| `len()` | 长度 | `len([1,2,3])` | `3` |
| `range()` | 整数序列 | `list(range(3))` | `[0,1,2]` |
| `enumerate()` | 带索引遍历 | `list(enumerate('ab'))` | `[(0,'a'),(1,'b')]` |
| `zip()` | 并行组合 | `list(zip([1,2],[3,4]))` | `[(1,3),(2,4)]` |
| `map()` | 映射 | `list(map(str,[1,2]))` | `['1','2']` |
| `filter()` | 过滤 | `list(filter(bool,[0,1,'']))` | `[1]` |
| `sorted()` | 排序 | `sorted([3,1,2])` | `[1,2,3]` |
| `reversed()` | 反转 | `list(reversed([1,2,3]))` | `[3,2,1]` |
| `all()` | 全为真 | `all([1,2,3])` | `True` |
| `any()` | 任一为真 | `any([0,0,1])` | `True` |
| `sum()` | 求和 | `sum([1,2,3])` | `6` |
| `min()` | 最小值 | `min([3,1,2])` | `1` |
| `max()` | 最大值 | `max([3,1,2])` | `3` |
| `abs()` | 绝对值 | `abs(-5)` | `5` |
| `round()` | 四舍五入 | `round(3.14, 1)` | `3.1` |
| `isinstance()` | 类型判断 | `isinstance(1, int)` | `True` |
| `type()` | 获取类型 | `type(1)` | `<class 'int'>` |
| `id()` | 对象标识 | `id(x)` | 内存地址 |
| `hash()` | 哈希值 | `hash('hello')` | 整数 |
| `dir()` | 属性列表 | `dir(str)` | 列表 |
| `help()` | 帮助文档 | `help(str.upper)` | 文档 |
| `input()` | 标准输入 | `input("请输入:")` | 字符串 |
| `print()` | 标准输出 | `print(1,2,sep=',')` | `1,2` |
| `open()` | 打开文件 | `open('f.txt','r')` | 文件对象 |
| `chr()`/`ord()` | 字符↔编码 | `chr(65)` / `ord('A')` | `'A'` / `65` |
| `eval()` | 执行表达式 | `eval('1+2')` | `3` |
| `exec()` | 执行代码 | `exec('x=1')` | 无返回 |

---

## 常用标准库

### os 模块

```python
import os

# 环境变量
os.getenv("HOME")           # '/Users/ms.chen'
os.getenv("NOT_EXIST", "默认值")
os.environ["MY_VAR"] = "value"  # 设置环境变量

# 路径操作（推荐用 pathlib 替代）
os.path.join("dir", "file.txt")  # 'dir/file.txt'
os.path.exists("/tmp")           # True
os.path.isfile("/tmp")           # False
os.path.isdir("/tmp")            # True
os.path.basename("/a/b/c.txt")   # 'c.txt'
os.path.dirname("/a/b/c.txt")    # '/a/b'
os.path.splitext("file.tar.gz")  # ('file.tar', '.gz')

# 目录操作
os.getcwd()                 # 当前工作目录
os.chdir("/tmp")            # 切换目录
os.listdir(".")             # 列出目录内容
os.mkdir("new_dir")         # 创建目录
os.makedirs("a/b/c", exist_ok=True)  # 递归创建
os.remove("file.txt")       # 删除文件
os.rmdir("empty_dir")       # 删除空目录
os.rename("old.txt", "new.txt")

# 执行系统命令
os.system("echo hello")     # 返回退出码
```

### sys 模块

```python
import sys

sys.argv           # 命令行参数列表 ['script.py', 'arg1']
sys.version        # Python 版本
sys.platform       # 'darwin' / 'win32' / 'linux'
sys.path           # 模块搜索路径
sys.exit(0)        # 退出程序
sys.stdout         # 标准输出
sys.stderr         # 标准错误
sys.stdin          # 标准输入
```

### json 模块

```python
import json

# 序列化（Python → JSON字符串）
data = {"name": "陈", "scores": [85, 92, 78]}
json_str = json.dumps(data, ensure_ascii=False, indent=2)

# 写入文件
with open("data.json", "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

# 反序列化（JSON字符串 → Python）
parsed = json.loads(json_str)

# 读取文件
with open("data.json", "r", encoding="utf-8") as f:
    parsed = json.load(f)

# Python ↔ JSON 类型映射
"""
Python          → JSON
dict            → object
list/tuple      → array
str             → string
int/float       → number
True/False      → true/false
None            → null
"""
```

### datetime 模块

```python
from datetime import datetime, date, time, timedelta

# 当前时间
now = datetime.now()
today = date.today()

# 创建
dt = datetime(2025, 6, 15, 14, 30, 0)
d = date(2025, 6, 15)
t = time(14, 30, 0)

# 格式化
dt.strftime("%Y-%m-%d %H:%M:%S")    # '2025-06-15 14:30:00'
dt.strftime("%Y年%m月%d日")           # '2025年06月15日'

# 解析
datetime.strptime("2025-06-15", "%Y-%m-%d")

# 时间差
delta = timedelta(days=7)
future = now + delta
past = now - delta
(future - now).days  # 7

# 时间戳
timestamp = dt.timestamp()           # → float
datetime.fromtimestamp(timestamp)    # → datetime

# 常用格式符
"""
%Y  四位年份    2025
%m  两位月份    06
%d  两位日期    15
%H  24小时制    14
%I  12小时制    02
%M  分钟        30
%S  秒          00
%A  星期全称    Sunday
%a  星期缩写    Sun
%B  月份全称    June
%b  月份缩写    Jun
%w  星期数字    0（周日=0）
%j  年内天数    166
"""
```

### collections 模块

```python
from collections import Counter, defaultdict, OrderedDict, deque, namedtuple

# Counter：计数器
words = ["苹果", "香蕉", "苹果", "橙子", "苹果", "香蕉"]
c = Counter(words)
c                      # Counter({'苹果': 3, '香蕉': 2, '橙子': 1})
c["苹果"]              # 3
c.most_common(2)       # [('苹果', 3), ('香蕉', 2)]
c.update(["苹果"])      # 增加计数
c.subtract(["苹果"])    # 减少计数

# defaultdict：默认值字典
dd = defaultdict(list)
dd["水果"].append("苹果")  # 不需要判断键是否存在
dd = defaultdict(int)      # 默认0，可用于计数
dd["hello"] += 1

# deque：双端队列
dq = deque([1, 2, 3])
dq.appendleft(0)       # 左端添加
dq.append(4)           # 右端添加
dq.popleft()           # 左端弹出
dq.pop()               # 右端弹出
dq.rotate(1)           # 右旋一位 → deque([3, 1, 2])

# namedtuple：命名元组（见"元组"章节）
```

### itertools 模块

```python
from itertools import chain, combinations, permutations, product, groupby

# chain：串联迭代器
list(chain([1, 2], [3, 4]))  # [1, 2, 3, 4]

# 排列组合
list(permutations([1, 2, 3], 2))   # [(1,2),(1,3),(2,1),(2,3),(3,1),(3,2)]
list(combinations([1, 2, 3], 2))   # [(1,2),(1,3),(2,3)]
list(product([1, 2], ['a', 'b']))  # [(1,'a'),(1,'b'),(2,'a'),(2,'b')]

# groupby：分组（需先排序）
data = [("A", 1), ("A", 2), ("B", 3), ("B", 4)]
for key, group in groupby(data, key=lambda x: x[0]):
    print(key, list(group))
```

---

## 类型提示

```python
from typing import (
    Optional, Union, List, Dict, Set, Tuple,
    Callable, Iterable, Any, TypeVar, Generic, Protocol
)

# 基本类型提示
def greet(name: str) -> str:
    return f"你好，{name}"

def add(a: int, b: int) -> int:
    return a + b

# 容器类型
def process(items: list[str]) -> dict[str, int]:
    return {item: len(item) for item in items}

# Python 3.9+ 可直接用内置类型
def f() -> list[int]: ...
# Python 3.8 需要从 typing 导入
def f() -> List[int]: ...

# Optional：可能为 None
def find_user(user_id: int) -> Optional[str]:
    ...  # 返回 str 或 None

# Union：多种类型
def parse(value: Union[str, int]) -> int:
    return int(value)

# Python 3.10+ 可用 X | Y 语法
def parse(value: str | int) -> int: ...
def find_user(user_id: int) -> str | None: ...

# Callable：可调用对象
def apply(func: Callable[[int, int], int], a: int, b: int) -> int:
    return func(a, b)

# 泛型
T = TypeVar('T')

def first(items: list[T]) -> T:
    return items[0]

class Stack(Generic[T]):
    def __init__(self) -> None:
        self._items: list[T] = []
    
    def push(self, item: T) -> None:
        self._items.append(item)
    
    def pop(self) -> T:
        return self._items.pop()
```

---

## 推导式

### 列表推导式

```python
# 基本形式
squares = [x ** 2 for x in range(10)]
# [0, 1, 4, 9, 16, 25, 36, 49, 64, 81]

# 带条件过滤
evens = [x for x in range(20) if x % 2 == 0]

# 带条件表达式
labels = ["偶" if x % 2 == 0 else "奇" for x in range(5)]
# ['偶', '奇', '偶', '奇', '偶']

# 嵌套循环
pairs = [(x, y) for x in range(3) for y in range(3)]
# [(0,0),(0,1),(0,2),(1,0),(1,1),(1,2),(2,0),(2,1),(2,2)]

# 嵌套推导式（矩阵转置）
matrix = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
transposed = [[row[i] for row in matrix] for i in range(3)]
# [[1,4,7],[2,5,8],[3,6,9]]

# 展平
flat = [x for row in matrix for x in row]
# [1,2,3,4,5,6,7,8,9]
```

### 字典推导式

```python
# 基本
word_lengths = {word: len(word) for word in ["hello", "world"]}
# {'hello': 5, 'world': 5}

# 键值互换
d = {"a": 1, "b": 2}
inverted = {v: k for k, v in d.items()}
# {1: 'a', 2: 'b'}

# 条件过滤
scores = {"陈": 85, "李": 45, "王": 92}
passed = {name: score for name, score in scores.items() if score >= 60}
# {'陈': 85, '王': 92}
```

### 集合推导式

```python
# 去重 + 变换
words = ["hello", "world", "hi"]
lengths = {len(word) for word in words}
# {5, 2}
```
