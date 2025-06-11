-- 人大金仓触发器批量部署脚本
-- 按推荐顺序执行所有触发器

-- ================================
-- 1. 部署 update_balance_paid_sum_change 触发器
-- ================================
\echo '正在部署 update_balance_paid_sum_change 触发器...'
\i update_balance_paid_sum_change.sql
\echo 'update_balance_paid_sum_change 触发器部署完成'

-- ================================  
-- 2. 部署 update_balance_unpaid_sum_change 触发器
-- ================================
\echo '正在部署 update_balance_unpaid_sum_change 触发器...'
\i update_balance_unpaid_sum_change.sql
\echo 'update_balance_unpaid_sum_change 触发器部署完成'

-- ================================
-- 3. 部署 update_balance_paid_change 触发器  
-- ================================
\echo '正在部署 update_balance_paid_change 触发器...'
\i update_balance_paid_change.sql
\echo 'update_balance_paid_change 触发器部署完成'

-- ================================
-- 4. 部署 update_funds_change 触发器
-- ================================
\echo '正在部署 update_funds_change 触发器...'
\i update_funds_change.sql
\echo 'update_funds_change 触发器部署完成'

\echo '===================='
\echo '所有触发器部署完成！'
\echo '===================='

-- 验证触发器是否创建成功
\echo '验证触发器创建情况：'
SELECT trigger_name, event_manipulation, event_object_table, action_timing
FROM information_schema.triggers 
WHERE trigger_schema = current_database()
  AND trigger_name IN (
    'update_balance_paid_change',
    'update_balance_paid_sum_change', 
    'update_balance_unpaid_sum_change',
    'update_funds_change'
  )
ORDER BY trigger_name; 