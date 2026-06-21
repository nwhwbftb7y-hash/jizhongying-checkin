-- 在 Supabase SQL Editor 中完整执行一次。
-- Supabase Cron 默认按 UTC 调度；UTC 16:00 即北京时间次日 00:00。

create extension if not exists pg_cron with schema extensions;

-- 允许重复执行本文件：先移除旧的同名任务，避免创建多个清理任务。
do $$
declare
  existing_job record;
begin
  for existing_job in
    select jobid from cron.job where jobname = 'clear-daily-checkins'
  loop
    perform cron.unschedule(existing_job.jobid);
  end loop;
end
$$;

select cron.schedule(
  'clear-daily-checkins',
  '0 16 * * *',
  $$delete from public.checkins;$$
);

-- 查看任务是否创建成功：应返回一行 active = true。
select jobid, jobname, schedule, command, active
from cron.job
where jobname = 'clear-daily-checkins';
