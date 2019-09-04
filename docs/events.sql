-- 创建存储过程
-- 更新试卷状态的存储过程
drop procedure if exists update_status;
create procedure update_status()
begin
	update users
	set status=1
	where startime<=now()
	and endtime>=now()
	and status<>2;
 
	update users
	set status=3
	where endtime<now();
end;

-- 开启event_scheduler
SHOW VARIABLES LIKE '%event_scheduler'
SET GLOBAL event_scheduler=1

-- 创建定时任务
-- 每60s执行一次
DROP EVENT IF EXISTS e_updateStatus; -- 删除事件
CREATE EVENT IF NOT EXISTS e_updateStatus
ON schedule every 10 second  -- 设置10秒执行一次
starts date_add(NOW(),interval 10 second) -- 在10后执行
ON completion preserve 
do call update_status();
  
-- 开启事件任务
alter EVENT e_updateStatus ON
COMPLETION PRESERVE ENABLE;

-- 关闭事件任务
alter EVENT e_updateStatus ON
COMPLETION PRESERVE DISABLE;


/*
event history
https://blog.csdn.net/seteor/article/details/19411717
1. 创建作业执行Event历史记录表
2. 根据以下建模板创建作业
*/

CREATE TABLE `mysql`.`t_event_history` (
  `dbname` VARCHAR(128) NOT NULL DEFAULT '',
  `eventname` VARCHAR(128) NOT NULL DEFAULT '',
  `starttime` DATETIME NOT NULL DEFAULT NOW(),
  `endtime` DATETIME DEFAULT NULL,
  `issuccess` INT(11) DEFAULT NULL,
  `duration` INT(11) DEFAULT NULL,
  `errormessage` VARCHAR(512) DEFAULT NULL,
  `randno` INT(11) DEFAULT NULL,
  PRIMARY KEY (`dbname`,`eventname`,`starttime`),
  KEY `ix_endtime` (`endtime`),
  KEY `ix_starttime_randno` (`starttime`,`randno`)
) ENGINE=INNODB DEFAULT CHARSET=utf8;

-- define procedure
CREATE DEFINER=`root`@`localhost` PROCEDURE `make_clock`()
BEGIN
	INSERT INTO clock (create_at) VALUES (NOW());
END

-- define event
DROP EVENT IF EXISTS e_clock;
DELIMITER $$  
CREATE DEFINER=`root`@`localhost` EVENT `e_clock` ON SCHEDULE   
#修改以下调度信息  
EVERY 1 DAY STARTS '2019-09-02 00:00:00' ON COMPLETION PRESERVE ENABLE DO   
BEGIN  
    DECLARE r_code CHAR(5) DEFAULT '00000';  
    DECLARE r_msg TEXT;  
    DECLARE v_error INTEGER;  
    DECLARE v_starttime DATETIME DEFAULT NOW();  
    DECLARE v_randno INTEGER DEFAULT FLOOR(RAND()*100001);  
      
    INSERT INTO mysql.t_event_history (dbname,eventname,starttime,randno)   
    #修改下面的作业名（该作业的名称）  
    VALUES(DATABASE(),'e_clock', v_starttime,v_randno);    
      
    BEGIN  
        # 异常处理段  
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION    
        BEGIN  
            SET  v_error = 1;  
            GET DIAGNOSTICS CONDITION 1 r_code = RETURNED_SQLSTATE , r_msg = MESSAGE_TEXT;  
        END;  
          
        # 此处为实际调用的用户程序过程  
        CALL test.make_clock();  
    END;  
      
    UPDATE mysql.t_event_history SET endtime=NOW(),issuccess=ISNULL(v_error),duration=TIMESTAMPDIFF(SECOND,starttime,NOW()), errormessage=CONCAT('error=',r_code,', message=',r_msg),randno=NULL WHERE starttime=v_starttime AND randno=v_randno;  
      
END$$  
DELIMITER;  
