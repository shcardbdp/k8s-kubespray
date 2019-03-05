#!/bin/bash


function begin_log_step() {
  step_num=$1
  begin_step=$(date +%Y%m%d%H%M%S)
}


function end_log_step() {
  local step_num=$1
  local model_name=$2
  local job_date=$(date +%Y%m%d)
  local end_step=$(date +%Y%m%d%H%M%S)
  local insert_query="INSERT INTO BGPADM.BBDPK0005( DP_CED, DP_BAT_PGM_NM, BAT_STG_N,RM_SR_DT,RM_ED_DT, RM_ND_TM,PS_CT, BAT_PGS_UCD,BAT_ERO_CD,BAT_ERO_MSG_TT,YARN_ID) VALUES ( '$job_date', '$model_name', '$step_num', '$begin_step','$end_step', null,0,'E',null,null,null);"

  echo $insert_query | sqlplus 
  return 0
}  

 
begin_log_step "001"

# edw 또는 datalake에서 원하는 table을 query 하여 주어진 위치, /home/jovyan/notebooks/data에 query 결과를 -o 옵션에서지정한 csv 파일을 생성

# datalake에서 table, edb.hbat_mcbsc0199_69에 대한 조회 결과를 /home/jovyan/notebooks/data/hive10.csv에 파일로 저장
#jdbc-cli  -t hive -o hive10.csv -q "SELECT * FROM edb.hbat_mcbsc0199_69 limit 10000" -s "," 

# edw에서 table, SC202079.SHC_MCT에 대한 조회 결과를 /home/jovyan/notebooks/data/SHC_MCT.csv에 파일로 저장
#jdbc-cli  -t oracle -o SHC_MCT.csv -q "SELECT * FROM SC202079.SHC_MCT"

# 파이썬 프로그램 hobbymode.py 프로그램을 argument '201803' 과 실행 
#python $HOME/notebooks/src/hobbymodel.py '201803'

end_log_step "001" "MD_HSIIFJ0031_01"
