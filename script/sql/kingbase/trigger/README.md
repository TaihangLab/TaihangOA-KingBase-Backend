# 人大金仓触发器迁移说明

本目录包含从MySQL迁移到人大金仓数据库的触发器代码。

## 文件清单

1. `update_balance_paid_change.sql` - 项目余额已支付变更触发器
2. `update_balance_paid_sum_change.sql` - 项目余额已支付汇总变更触发器  
3. `update_balance_unpaid_sum_change.sql` - 项目余额未支付汇总变更触发器
4. `update_funds_change.sql` - 项目预算资金变更触发器

## 主要语法变化

### 1. 触发器定义语法
**MySQL:**
```sql
CREATE DEFINER=`root`@`localhost` TRIGGER `trigger_name` 
AFTER UPDATE ON `table_name` FOR EACH ROW
BEGIN
  -- 触发器逻辑
END
```

**人大金仓:**
```sql
-- 创建触发器函数
CREATE OR REPLACE FUNCTION trigger_name_func()
RETURNS TRIGGER AS $$
BEGIN
  -- 触发器逻辑
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 创建触发器
CREATE TRIGGER trigger_name
    AFTER UPDATE ON table_name
    FOR EACH ROW
    EXECUTE FUNCTION trigger_name_func();
```

### 2. 主要差异说明

1. **DEFINER语法**: 人大金仓不需要DEFINER子句
2. **函数+触发器模式**: 人大金仓使用函数+触发器的模式，而MySQL直接在触发器中定义逻辑
3. **返回值**: 人大金仓的触发器函数必须有返回值(`RETURN NEW;`或`RETURN OLD;`)
4. **语言标识**: 需要指定`LANGUAGE plpgsql`
5. **分隔符**: 使用`$$...$$`作为函数体分隔符，而不是MySQL的`DELIMITER`

### 3. 触发器功能说明

- **update_balance_paid_change**: 当项目余额已支付表更新时，自动更新对应的未支付余额
- **update_balance_paid_sum_change**: 更新前计算已支付金额的各种汇总值
- **update_balance_unpaid_sum_change**: 更新前计算未支付金额的各种汇总值  
- **update_funds_change**: 当项目资金表更新时，自动重新计算未支付余额

### 4. 部署顺序

建议按以下顺序执行SQL文件：
1. `update_balance_paid_sum_change.sql`
2. `update_balance_unpaid_sum_change.sql` 
3. `update_balance_paid_change.sql`
4. `update_funds_change.sql`

### 5. 注意事项

1. 执行前请确保相关表结构已经创建完成
2. 如果触发器已存在，脚本会先删除再重建
3. 请在测试环境充分验证后再在生产环境部署
4. 触发器逻辑保持与MySQL版本完全一致，仅语法做了适配

## 验证方法

部署完成后，可以通过以下SQL验证触发器是否正常工作：

```sql
-- 查看触发器是否创建成功
SELECT trigger_name, event_manipulation, event_object_table, action_timing
FROM information_schema.triggers 
WHERE trigger_schema = current_database();

-- 查看触发器函数是否创建成功  
SELECT proname, prosrc 
FROM pg_proc 
WHERE proname LIKE '%change_func';
``` 