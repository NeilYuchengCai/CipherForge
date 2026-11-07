# CipherForge — 密码学工具箱

一套面向桌面和Web的本地密码学工具集，涵盖对称加密、后量子签名、哈希与密钥派生、秘密共享、图片隐写、级联加密及高熵密码生成。代码公开可审计，所有密钥与盐均来自操作系统CSPRNG，不使用硬编码密钥。

[Python ≥3.12](https://www.python.org/) · [MIT License](LICENSE) · [测试：422 passed](tests/) · [安全审计报告](docs/SECURITY_AUDIT.md)

---

## 模块概览

| 模块 | 功能 |
|------|------|
| `cipherforge.core` | 配置加载、异常体系、内存安全（`SecureBytes`）、CSPRNG封装、侧信道防护（`timing_jitter`、`TimingProfile`） |
| `cipherforge.crypto.symmetric` | AES-256-GCM、ChaCha20-Poly1305、XChaCha20-Poly1305、Serpent-GCM、Twofish-GCM，支持流式加解密 |
| `cipherforge.crypto.hashing` | SHA-2/3、BLAKE2b/s、SHAKE XOF、HMAC，支持Pepper派生 |
| `cipherforge.crypto.kdf` | Argon2id（自适应内存成本与并行度调参）、PBKDF2-HMAC-SHA256 |
| `cipherforge.crypto.password_generator` | 可定制字符集、易混淆字符过滤、Diceware密语生成、熵强度评估 |
| `cipherforge.crypto.shamir` | GF(256) 门限秘密共享，支持Base64文本分片与二维码输出/合并 |
| `cipherforge.crypto.steganography` | LSB图片隐写，将秘密数据嵌入载体图片最低有效位（需Pillow） |
| `cipherforge.crypto.cascade` | HKDF逐层派生子密钥 + HMAC链 + 头MAC完整性保护，支持任意层数嵌套加密 |
| `cipherforge.crypto.pq_signature` | ML-DSA-87 / FALCON-1024 / SLH-DSA后量子签名（依赖liboqs，缺失时优雅降级） |

---

## 设计准则

1. **默认安全**：所有密钥、盐、Nonce、Pepper均由`os.urandom()`或`secrets`生成，无硬编码材料。
2. **恒定时间**：涉及秘密比较的函数使用`hmac.compare_digest`，不以秘密作为分支条件。
3. **内存卫生**：敏感数据存放于`SecureBytes`缓冲区，使用完毕后覆写清零；Windows下使用`VirtualLock`锁定物理页，Linux下使用`mlock`。
4. **失败即安全**：异常路径会擦除中间产物，不暴露内部细节（如算法名称、异常类型、堆栈）。
5. **优雅降级**：可选依赖缺失时给出明确的中文提示，其余模块不受影响。

---

## 快速开始

### 命令行（CLI）

```bash
# 对称加密
python cli.py encrypt --algo AES-256-GCM --password "my-secret" \
    --in secret.txt --out secret.enc

# 对称解密
python cli.py decrypt --algo AES-256-GCM --password "my-secret" \
    --in secret.enc --out secret.txt

# 流式大文件加密
python cli.py stream-encrypt --algo ChaCha20-Poly1305 --password xxx \
    --in largefile.bin --out largefile.enc

# 哈希
python cli.py hash --algo SHA-256 --in data.bin

# 密码生成
python cli.py passgen --length 24
python cli.py passgen --length 24 --exclude-ambiguous
python cli.py passgen --passphrase --words 6

# Shamir秘密共享
python cli.py shamir-split --threshold 2 --total 2 --in secret.bin --out-dir shares/
python cli.py shamir-combine --shares shares/*.txt --out recovered.bin

# 后量子签名
python cli.py pq-keygen --algo ML-DSA-87 --out alice
python cli.py pq-sign --algo ML-DSA-87 --secret-key alice.sk \
    --in doc.txt --out doc.sig --days 30
python cli.py pq-verify --algo ML-DSA-87 --public-key alice.pk \
    --in doc.txt --bundle doc.sig

# 级联加密
python cli.py cascade-encrypt --layers "AES-256-GCM,ChaCha20-Poly1305" \
    --password xxx --in f.txt --out f.csc
```

双击 `cipherforge.bat` 进入交互模式，输入 `help` 查看可用命令；`cli.bat` 启动传统CLI模式。

### GUI

```bash
python run.py --gui
```

启动后进入图形界面（若`ttkbootstrap`可用则使用增强主题，否则自动降级为纯tkinter基础版）。支持对称加密、流式加密、哈希/Pepper、密码生成、Shamir共享、LSB隐写、级联加密、后量子签名共8个功能模块。

### Python API

```python
from cipherforge import SymmetricCipher, HashEngine, PasswordGenerator

# 对称加密
cipher = SymmetricCipher("AES-256-GCM")
blob = cipher.encrypt(b"hello world", password="correct horse battery staple")
plaintext = cipher.decrypt(blob, password="correct horse battery staple")

# 哈希
digest = HashEngine.digest("SHA-256", b"data")

# 密码生成
gen = PasswordGenerator()
pw = gen.generate(24, exclude_ambiguous=True)
entropy = gen.entropy_bits(pw, len(gen.default_charset()))
print(f"强度: {gen.strength_label(entropy)}")
```

---

## Web 界面

```bash
# 直接启动
python server.py              # 默认 http://127.0.0.1:8000
python server.py --port 9000  # 指定端口
python server.py --host 0.0.0.0  # 允许局域网访问

# 或使用快捷脚本
.\server.bat
```

启动后按提示选择 Localhost 或 LAN 模式。后端为 FastAPI，前端为原生JS SPA（静态文件托管于`static/`），提供以下API端点：

| 端点 | 方法 | 功能 |
|------|------|------|
| `/` | GET | 前端界面 |
| `/api/algorithms` | GET | 支持的算法列表 |
| `/api/encrypt` | POST | 对称加密 |
| `/api/decrypt` | POST | 对称解密 |
| `/api/stream-encrypt` | POST | 流式加密 |
| `/api/stream-decrypt` | POST | 流式解密 |
| `/api/hash` | POST | 哈希计算 |
| `/api/generate-password` | POST | 密码生成 |
| `/api/shamir-split` | POST | Shamir分片 |
| `/api/shamir-combine` | POST | Shamir合并 |
| `/api/cascade-encrypt` | POST | 级联加密 |
| `/api/cascade-decrypt` | POST | 级联解密 |
| `/api/pq-keygen` | POST | 后量子密钥对生成 |
| `/api/pq-sign` | POST | 后量子签名 |
| `/api/pq-verify` | POST | 后量子验证 |
| `/health` | GET | 健康检查 |

---

## 安全审计

本项目已通过全面安全审计，详见 [docs/SECURITY_AUDIT.md](docs/SECURITY_AUDIT.md)。

**安全评级**: 优秀 ✅（0 P0 漏洞，生产级安全标准）

**核心安全能力**:
- ✅ 100% CSPRNG 来源，零硬编码密钥
- ✅ 恒定时间比较，抗侧信道攻击
- ✅ SecureBytes 自动擦除 + 内存锁定（VirtualLock/mlock）
- ✅ KDF 派生密钥通过 `derive_secure()` 返回可擦除对象，立即零化
- ✅ API/GUI 层异常消息去敏感化
- ✅ 无 eval/exec/pickle 反序列化风险
- ✅ 前端无 innerHTML，防 XSS

**测试覆盖**: 422 tests passed | 96% 语句覆盖 | 96% 分支覆盖 | 38 安全专项测试

---

## 测试与覆盖率

```bash
# 运行测试
python -m pytest tests/ -q

# 覆盖率报告
python -m pytest --cov=cipherforge --cov-report=term-missing -q
```

当前状态：**422 tests passed**（运行时间约90秒）。

最新审计覆盖率：**96% 语句 / 96% 分支**（2500 语句，67 未覆盖）。

主要模块覆盖率如下：

| 模块 | 语句覆盖 | 备注 |
|------|---------|------|
| `core/rng.py` | 100% | |
| `crypto/_serpent.py` | 100% | |
| `crypto/_twofish.py` | 99% | |
| `crypto/shamir.py` | 98% | |
| `crypto/password_generator.py` | 99% | |
| `core/config.py` | 94% | |
| `core/memory.py` | 95% | |
| `crypto/symmetric.py` | 97% | 多算法分支已补充覆盖 |
| `crypto/cascade.py` | 99% | 多层嵌套场景已测试 |
| `crypto/pq_signature.py` | 98% | ML-DSA-87 覆盖完整 |
| **总计** | **96%** | 2500 语句，67 未覆盖 |

---

## 依赖

| 必需 | 版本 | 用途 |
|------|------|------|
| `cryptography` | ≥42.0 | AES-GCM / ChaCha20-Poly1305 |
| `pycryptodome` | ≥3.20 | Serpent / Twofish / 原语兼容 |
| `argon2-cffi` | ≥23.1 | Argon2id KDF |
| `pynacl` | ≥1.5 | XChaCha20-Poly1305（经libsodium） |
| `PyYAML` | ≥6.0.1 | 配置文件解析 |

| 可选 | 版本 | 用途 |
|------|------|------|
| `Pillow` | ≥10.2 | LSB隐写载体读写 |
| `qrcode` | ≥7.4.2 | Shamir分片二维码生成 |
| `ttkbootstrap` | ≥1.10 | GUI增强主题（自动降级为tkinter） |
| `liboqs-python` | ≥0.10.0 | 后量子签名（ML-DSA/FALCON/SLH-DSA） |
| `fastapi` + `uvicorn` | — | Web服务（`server.py`） |

---

## 构建

```bash
python build.py              # PyInstaller单文件打包（推荐）
python build.py --develop    # 开发模式，保留调试信息
```

产物位于 `dist/cipherforge`。

---

## 配置

项目根目录的 `config.yaml` 包含所有可调参数，包括：

- `symmetric.default_algorithm` / `streaming.chunk_size_mib`
- `kdf.argon2id.memory_cost_kib` / `parallelism`
- `pq_signature.default_algorithm`
- `security.side_channel.enabled`
- `gui.mode` / `gui.theme`

详见 [config.yaml](config.yaml)。

---

## 参考

- [RFC 8439](https://tools.ietf.org/html/rfc8439) — ChaCha20-Poly1305 AEAD
- [RFC 9106](https://tools.ietf.org/html/rfc9106) — XChaCha20-Poly1305
- [Argon2](https://argon2.online/) — IACR 2015 密码哈希竞赛冠军
- [liboqs](https://github.com/open-quantum-safe/liboqs) — 后量子密码学参考实现
- [NIST FIPS 202](https://nvlpubs.nist.gov/nistpubs/fips/nist.fips.202.pdf) — SHA-3 标准
