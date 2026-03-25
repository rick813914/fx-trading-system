"""
CSV 解析器基类
"""
import csv
from abc import ABC, abstractmethod
from typing import List, Dict, Any
import codecs

class BaseCSVParser(ABC):
    """CSV 解析器基类"""

    def __init__(self, file_content: bytes, encoding: str = 'utf-8-sig'):
        self.file_content = file_content
        self.encoding = encoding

    @abstractmethod
    def parse(self) -> tuple[List[Dict[str, Any]], List[str]]:
        """
        解析 CSV 内容，返回订单数据字典列表和错误列表
        """
        pass

    def _read_csv(self) -> List[Dict]:
        """读取 CSV 为字典列表，自动处理 BOM"""
        text = codecs.decode(self.file_content, self.encoding)
        print(f"解码后文本前200字符: {text[:200]}")
        lines = text.splitlines()
        print(f"总行数: {len(lines)}")
        reader = csv.DictReader(lines)
        rows = list(reader)
        print(f"解析后行数: {len(rows)}")
        if rows:
            print("列名:", list(rows[0].keys()))
        return rows