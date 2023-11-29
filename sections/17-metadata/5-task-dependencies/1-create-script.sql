create or replace database tasks_db;

create task task1 schedule = '60 minute' as select system$wait(1);
create task task2 after task1 as select system$wait(2);
create task task3 after task1 as select system$wait(1);
create task task4 after task2, task3 as select system$wait(1);
create task task5 after task1, task4 as select system$wait(1);
create task task6 after task5 as select system$wait(1);
create task task7 after task6 as select system$wait(1);
create task task8 after task6 as select system$wait(2);