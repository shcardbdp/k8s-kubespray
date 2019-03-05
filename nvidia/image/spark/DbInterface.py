import os
import sys
import time
import random
import pandas as pd
import datetime
import numpy as np
import collections

from pyspark.sql import SparkSession

# def dbGetTableQuerySparkDF(spark: SparkSession, dbtable: str, query: str):

def dbGetTableQuerySparkDF(spark: SparkSession, dbtable: str):
    """
    EDW에서 Query 를 실행한 결과물을 Spark DataFrame으로 반환한다.
    
    :param spark: 실행중인 SparkSession 인스턴스.
    :param dbtable: 쿼리하고자하는 EDW의 테이블 명 또는 괄호로 감싼 쿼리문
    
    .. note:: 
        properties 파일에서 대상 DB 접속 정보를 가져온다.
        
    :return: 
        EDW로부터 쿼리한 Spark DataFrame (Action 발생 시 로드 된다.)
        [실행 예제]
        jdbcDF = dbGetTableQuerySparkDF(spark, "(SELECT * FROM BBDPF0001 WHERE rownum <= 10)")
        jdbcDF.show()
        
        jdbcDF = dbGetTableQuerySparkDF(spark, "BBDPF0001")
        jdbcDF.show()
    
    """
    d = {}
    with open("/etc/datalake/datalake.properties") as f:
        l = [line.split("=") for line in f.readlines()]
        l = [t for t in l if len(t) == 2]
        d = {key.strip(): value.strip() for key, value in l}
    url = d['oracle.datasource.url'] 
    user = d['oracle.datasource.username'] 
    password = d['oracle.datasource.password'] 
    numPartitions = 1
    fetchSize = 10000        
    retDF = spark \
        .read \
        .format("jdbc") \
        .option("url", url) \
        .option("user", user).option("password", password) \
        .option("numPartitions", numPartitions) \
        .option("fetchSize", fetchSize) \
        .option("dbtable", dbtable) \
        .load()
    return retDF

def dbGetQuery(query: str, source: str='oracle', sep: str=',', clean_outfile: bool=True, dtype=None):
    """
    데이터베이스에서 query 를 실행한 결과물을 DataFrame으로 반환한다.

    params
    query: str, valid query statement
    source: str, data source, hive or oracle
    sep: str, 분할자, default ','

    return
    df: DataFrame
    예시:
    df = dfGetQuery("SELECT * from SC202079.SHC_MCT")
    """

    PREFIX_OUTFILE = '/home/jovyan/notebooks/data/'
    outfile = "temp%d.csv" % random.randint(0, 1e10)
    cmd = 'jdbc-cli -t {} -o {} -q "{}" -s "{}"'.format(source, outfile, query, sep)
    print('cmd:' + cmd)
    os.system(command=cmd)
    df = pd.read_csv(PREFIX_OUTFILE + outfile, error_bad_lines=False, encoding='utf-8', sep=sep, dtype=dtype)

    if clean_outfile:
        os.system(command='rm %s' % PREFIX_OUTFILE + outfile)

    return df
	
def read_csv(filepath, chunksize=2**16, **kwargs):
    
    # get number of rows
    with open(filepath, 'r') as f:
        nrow = sum(1 for line in f)
    nrow -= 1   # header
    progbar = Progbar(nrow)
    chunks = []
    row = 0
    for chunk in pd.read_csv(filepath, chunksize=chunksize, **kwargs):
        chunks.append(chunk)
        row += len(chunk)
        progbar.update(row)
    return pd.concat(chunks)
        
#brought from KERAS 
class Progbar(object):
    """Displays a progress bar.

    # Arguments
        target: Total number of steps expected, None if unknown.
        width: Progress bar width on screen.
        verbose: Verbosity mode, 0 (silent), 1 (verbose), 2 (semi-verbose)
        stateful_metrics: Iterable of string names of metrics that
            should *not* be averaged over time. Metrics in this list
            will be displayed as-is. All others will be averaged
            by the progbar before display.
        interval: Minimum visual progress update interval (in seconds).
    """

    def __init__(self, target, width=30, verbose=1, interval=0.05,
                 stateful_metrics=None):
        self.target = target
        self.width = width
        self.verbose = verbose
        self.interval = interval
        if stateful_metrics:
            self.stateful_metrics = set(stateful_metrics)
        else:
            self.stateful_metrics = set()

        self._dynamic_display = ((hasattr(sys.stdout, 'isatty') and
                                  sys.stdout.isatty()) or
                                 'ipykernel' in sys.modules)
        self._total_width = 0
        self._seen_so_far = 0
        self._values = collections.OrderedDict()
        self._start = time.time()
        self._last_update = 0

    def update(self, current, values=None):
        """Updates the progress bar.

        # Arguments
            current: Index of current step.
            values: List of tuples:
                `(name, value_for_last_step)`.
                If `name` is in `stateful_metrics`,
                `value_for_last_step` will be displayed as-is.
                Else, an average of the metric over time will be displayed.
        """
        values = values or []
        for k, v in values:
            if k not in self.stateful_metrics:
                if k not in self._values:
                    self._values[k] = [v * (current - self._seen_so_far),
                                       current - self._seen_so_far]
                else:
                    self._values[k][0] += v * (current - self._seen_so_far)
                    self._values[k][1] += (current - self._seen_so_far)
            else:
                self._values[k] = v
        self._seen_so_far = current

        now = time.time()
        info = ' - %.0fs' % (now - self._start)
        if self.verbose == 1:
            if (now - self._last_update < self.interval and
                    self.target is not None and current < self.target):
                return

            prev_total_width = self._total_width
            if self._dynamic_display:
                sys.stdout.write('\b' * prev_total_width)
                sys.stdout.write('\r')
            else:
                sys.stdout.write('\n')

            if self.target is not None:
                numdigits = int(np.floor(np.log10(self.target))) + 1
                barstr = '%%%dd/%d [' % (numdigits, self.target)
                bar = barstr % current
                prog = float(current) / self.target
                prog_width = int(self.width * prog)
                if prog_width > 0:
                    bar += ('=' * (prog_width - 1))
                    if current < self.target:
                        bar += '>'
                    else:
                        bar += '='
                bar += ('.' * (self.width - prog_width))
                bar += ']'
            else:
                bar = '%7d/Unknown' % current

            self._total_width = len(bar)
            sys.stdout.write(bar)

            if current:
                time_per_unit = (now - self._start) / current
            else:
                time_per_unit = 0
            if self.target is not None and current < self.target:
                eta = time_per_unit * (self.target - current)
                if eta > 3600:
                    eta_format = '%d:%02d:%02d' % (eta // 3600, (eta % 3600) // 60, eta % 60)
                elif eta > 60:
                    eta_format = '%d:%02d' % (eta // 60, eta % 60)
                else:
                    eta_format = '%ds' % eta

                info = ' - ETA: %s' % eta_format
            else:
                if time_per_unit >= 1:
                    info += ' %.0fs/step' % time_per_unit
                elif time_per_unit >= 1e-3:
                    info += ' %.0fms/step' % (time_per_unit * 1e3)
                else:
                    info += ' %.0fus/step' % (time_per_unit * 1e6)

            for k in self._values:
                info += ' - %s:' % k
                if isinstance(self._values[k], list):
                    avg = np.mean(
                        self._values[k][0] / max(1, self._values[k][1]))
                    if abs(avg) > 1e-3:
                        info += ' %.4f' % avg
                    else:
                        info += ' %.4e' % avg
                else:
                    info += ' %s' % self._values[k]

            self._total_width += len(info)
            if prev_total_width > self._total_width:
                info += (' ' * (prev_total_width - self._total_width))

            if self.target is not None and current >= self.target:
                info += '\n'

            sys.stdout.write(info)
            sys.stdout.flush()

        elif self.verbose == 2:
            if self.target is None or current >= self.target:
                for k in self._values:
                    info += ' - %s:' % k
                    avg = np.mean(
                        self._values[k][0] / max(1, self._values[k][1]))
                    if avg > 1e-3:
                        info += ' %.4f' % avg
                    else:
                        info += ' %.4e' % avg
                info += '\n'

                sys.stdout.write(info)
                sys.stdout.flush()

        self._last_update = now

    def add(self, n, values=None):
        self.update(self._seen_so_far + n, values)
	