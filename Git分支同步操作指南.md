# Git 分支同步操作指南 - SQLBot Fork 项目

## 📋 当前状态分析

### 现有配置
- **Origin (你的 Fork)**: https://github.com/1234-i/weisoftSQLAI.git
- **本地分支**: 
  - `main` - 停留在 v1.1.4 (commit: f79bdcf)
  - `weisoftSQLAI` - 包含自定义修改 (2个新提交)
- **上游官方仓库**: https://github.com/dataease/SQLBot (需要添加)

### 自定义修改
在 `weisoftSQLAI` 分支上的修改:
1. e398614 - 把系统颜色修改为紫色,并且添加了测试数据
2. 8f07648 - 修改了一些图标

---

## 🎯 目标

1. ✅ 添加上游官方仓库作为 remote
2. ✅ 将本地 `main` 分支更新到官方 v1.2
3. ✅ 将 `weisoftSQLAI` 分支的自定义修改合并到 v1.2
4. ✅ 建立长期同步机制

---

## ⚠️ 重要提示

**操作前必读**:
- 所有操作都是可逆的,不用担心
- 我们会先创建备份分支
- 遇到冲突时可以随时中止
- 建议在操作前提交所有未保存的更改

---

## 📦 步骤 1: 创建备份分支 (安全第一!)

在开始任何操作前,先创建备份:

```bash
# 备份当前的 weisoftSQLAI 分支
git branch weisoftSQLAI-backup

# 备份 main 分支
git checkout main
git branch main-backup

# 返回工作分支
git checkout weisoftSQLAI

# 验证备份
git branch
```

**预期结果**: 看到 `weisoftSQLAI-backup` 和 `main-backup` 分支

---

## 🔗 步骤 2: 添加上游官方仓库

```bash
# 添加上游仓库 (upstream)
git remote add upstream https://github.com/dataease/SQLBot.git

# 验证 remote 配置
git remote -v
```

**预期结果**:
```
origin    https://github.com/1234-i/weisoftSQLAI.git (fetch)
origin    https://github.com/1234-i/weisoftSQLAI.git (push)
upstream  https://github.com/dataease/SQLBot.git (fetch)
upstream  https://github.com/dataease/SQLBot.git (push)
```

---

## 📥 步骤 3: 拉取上游最新代码

```bash
# 拉取上游所有分支和标签
git fetch upstream

# 查看上游的标签 (版本)
git tag -l | grep -E "v1\.[12]"

# 或者查看上游的提交历史
git log upstream/main --oneline -10
```

**预期结果**: 看到 v1.2.0 或类似的标签

---

## 🔄 步骤 4: 更新本地 main 分支到 v1.2

### 方法 A: 使用 merge (推荐,保留完整历史)

```bash
# 切换到 main 分支
git checkout main

# 合并上游的 main 分支
git merge upstream/main

# 或者合并特定的 v1.2 标签
git merge v1.2.0  # 如果存在 v1.2.0 标签

# 查看更新后的状态
git log --oneline -10
```

### 方法 B: 使用 rebase (线性历史,但会改写历史)

```bash
# 切换到 main 分支
git checkout main

# Rebase 到上游 main
git rebase upstream/main

# 如果遇到冲突,解决后继续
git rebase --continue
```

**推荐使用方法 A (merge)** 因为:
- 保留完整的历史记录
- 不会改写已发布的提交
- 更安全,易于回滚

---

## 🔀 步骤 5: 将自定义修改合并到更新后的 main

现在 `main` 分支已经是 v1.2 了,我们需要将 `weisoftSQLAI` 的修改应用上去。

### 策略选择

#### 选项 1: Rebase (推荐 ⭐)

**优点**:
- 保持线性的提交历史
- 你的自定义提交会出现在 v1.2 之后
- 历史更清晰,易于理解

**缺点**:
- 会改写 `weisoftSQLAI` 分支的历史
- 如果已经推送到远程,需要强制推送

**操作步骤**:

```bash
# 切换到 weisoftSQLAI 分支
git checkout weisoftSQLAI

# Rebase 到更新后的 main 分支
git rebase main

# 如果遇到冲突,会暂停并提示
# 解决冲突后:
git add <冲突文件>
git rebase --continue

# 如果想中止 rebase:
git rebase --abort
```

#### 选项 2: Merge (保守策略)

**优点**:
- 不改写历史
- 保留所有分支信息
- 更安全

**缺点**:
- 历史图会有分叉
- 提交历史较复杂

**操作步骤**:

```bash
# 切换到 weisoftSQLAI 分支
git checkout weisoftSQLAI

# 合并更新后的 main 分支
git merge main

# 解决冲突(如果有)
git add <冲突文件>
git commit
```

---

## 🛠️ 步骤 6: 处理合并冲突 (如果出现)

### 识别冲突

```bash
# 查看冲突文件
git status

# 查看冲突内容
git diff
```

### 解决冲突

冲突文件会包含类似这样的标记:

```
<<<<<<< HEAD (你的修改)
const customColor = ref('#6366F1')  // 蓝紫色
=======
const customColor = ref('#1CBA90')  // 官方的绿色
>>>>>>> main (上游的修改)
```

**解决步骤**:

1. **手动编辑冲突文件**,保留你需要的内容:
   ```javascript
   const customColor = ref('#6366F1')  // 保留你的蓝紫色
   ```

2. **删除冲突标记** (`<<<<<<<`, `=======`, `>>>>>>>`)

3. **标记为已解决**:
   ```bash
   git add <冲突文件>
   ```

4. **继续操作**:
   ```bash
   # 如果是 rebase
   git rebase --continue
   
   # 如果是 merge
   git commit
   ```

### 常见冲突场景

#### 场景 1: 主题颜色冲突
- **你的修改**: 蓝紫色 `#6366F1`
- **官方修改**: 可能更新了颜色系统
- **解决**: 保留你的颜色,但检查是否有新的颜色变量需要同步修改

#### 场景 2: 配置文件冲突
- **你的修改**: 自定义配置
- **官方修改**: 新增配置项
- **解决**: 合并两者,保留你的自定义 + 添加官方新配置

#### 场景 3: 依赖版本冲突
- **你的修改**: 可能没有
- **官方修改**: 升级了依赖版本
- **解决**: 使用官方的新版本

---

## 🔍 步骤 7: 验证合并结果

```bash
# 查看提交历史
git log --oneline --graph -20

# 查看你的自定义修改是否还在
git log --oneline --author="你的名字" -10

# 检查关键文件
git show HEAD:frontend/src/stores/appearance.ts | grep -A 2 "customColor"

# 运行测试 (如果有)
cd frontend && npm run build
cd backend && python -m pytest
```

---

## 📤 步骤 8: 推送到远程仓库

### 如果使用了 Rebase (改写了历史)

```bash
# 强制推送 weisoftSQLAI 分支 (谨慎!)
git push origin weisoftSQLAI --force-with-lease

# 推送更新后的 main 分支
git checkout main
git push origin main
```

**注意**: `--force-with-lease` 比 `--force` 更安全,它会检查远程是否有其他人的提交

### 如果使用了 Merge (没有改写历史)

```bash
# 正常推送
git push origin weisoftSQLAI

# 推送 main 分支
git checkout main
git push origin main
```

---

## 🔄 步骤 9: 建立长期同步机制

### 定期同步上游更新

创建一个脚本 `sync-upstream.sh`:

```bash
#!/bin/bash
# 同步上游官方仓库的脚本

echo "🔄 开始同步上游仓库..."

# 1. 拉取上游最新代码
echo "📥 拉取上游代码..."
git fetch upstream

# 2. 切换到 main 分支
echo "🔀 切换到 main 分支..."
git checkout main

# 3. 合并上游 main
echo "🔗 合并上游更新..."
git merge upstream/main

# 4. 推送到你的 fork
echo "📤 推送到远程..."
git push origin main

# 5. 切换回工作分支
echo "🔙 切换回 weisoftSQLAI 分支..."
git checkout weisoftSQLAI

# 6. Rebase 到最新的 main
echo "🔄 Rebase 工作分支..."
git rebase main

echo "✅ 同步完成!"
echo "⚠️  如果有冲突,请手动解决后运行: git rebase --continue"
```

**使用方法**:

```bash
# 赋予执行权限
chmod +x sync-upstream.sh

# 运行同步
./sync-upstream.sh
```

---

## 🚨 紧急回滚方案

如果操作出错,可以随时回滚:

### 回滚到备份分支

```bash
# 回滚 weisoftSQLAI 分支
git checkout weisoftSQLAI
git reset --hard weisoftSQLAI-backup

# 回滚 main 分支
git checkout main
git reset --hard main-backup
```

### 使用 reflog 恢复

```bash
# 查看操作历史
git reflog

# 恢复到特定的提交
git reset --hard HEAD@{n}  # n 是 reflog 中的编号
```

---

## 📊 推荐的工作流程

### 日常开发

```
upstream/main (官方)
    ↓ (定期同步)
main (你的主分支,跟踪官方)
    ↓ (rebase)
weisoftSQLAI (你的开发分支)
```

### 版本更新流程

1. **官方发布新版本** (如 v1.3)
2. **同步到 main**: `git checkout main && git merge upstream/main`
3. **更新开发分支**: `git checkout weisoftSQLAI && git rebase main`
4. **解决冲突** (如果有)
5. **测试验证**
6. **推送**: `git push origin weisoftSQLAI --force-with-lease`

---

## 🎓 最佳实践

1. **频繁同步**: 每周或每两周同步一次上游,避免积累太多冲突
2. **小步提交**: 将大的修改拆分成多个小提交,便于 rebase
3. **描述清晰**: 提交信息要清晰,方便以后查找
4. **保留备份**: 重要操作前总是创建备份分支
5. **测试验证**: 合并后务必运行测试,确保功能正常

---

## 📝 常用命令速查

```bash
# 查看远程仓库
git remote -v

# 查看所有分支
git branch -a

# 查看提交历史
git log --oneline --graph -20

# 查看当前状态
git status

# 拉取上游更新
git fetch upstream

# 合并上游 main
git merge upstream/main

# Rebase 到 main
git rebase main

# 中止 rebase
git rebase --abort

# 继续 rebase
git rebase --continue

# 强制推送 (谨慎!)
git push origin weisoftSQLAI --force-with-lease

# 查看冲突文件
git diff --name-only --diff-filter=U

# 恢复文件
git checkout -- <文件名>
```

---

## ❓ 常见问题

### Q1: Rebase 和 Merge 到底选哪个?

**A**: 
- **Rebase**: 适合个人开发分支,历史清晰
- **Merge**: 适合团队协作,保留完整历史
- **推荐**: 对于你的场景,使用 **Rebase** 更合适

### Q2: 强制推送会不会丢失数据?

**A**: 使用 `--force-with-lease` 而不是 `--force`,它会检查远程是否有新提交,更安全

### Q3: 如果冲突太多怎么办?

**A**: 
1. 先 `git rebase --abort` 中止
2. 使用 `git merge` 代替 `git rebase`
3. 或者逐个文件手动合并

### Q4: 如何查看我做了哪些自定义修改?

**A**:
```bash
# 查看与 main 分支的差异
git diff main..weisoftSQLAI

# 查看修改的文件列表
git diff main..weisoftSQLAI --name-only
```

---

## 🎯 下一步行动清单

- [ ] 创建备份分支
- [ ] 添加 upstream remote
- [ ] 拉取上游代码
- [ ] 更新 main 分支到 v1.2
- [ ] Rebase weisoftSQLAI 分支
- [ ] 解决冲突 (如果有)
- [ ] 测试验证
- [ ] 推送到远程
- [ ] 创建同步脚本

---

需要我帮你执行这些操作吗?我可以一步步指导你完成!
