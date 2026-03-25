"""
CSV 解析器基类
"""
import csv
from abc import ABC, abstractmethod
from typing import List, Dict, Any


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
        """读取 CSV 为字典列表"""
        text = self.file_content.decode(self.encoding)
        reader = csv.DictReader(text.splitlines())
        return list(reader)