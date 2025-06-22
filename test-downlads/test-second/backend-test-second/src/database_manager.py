"""
PostgreSQL Database Manager with SQLAlchemy
Singleton pattern with raw SQL support
"""
import os
import logging
from typing import Optional, Any, Dict, List, Union
from contextlib import contextmanager
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from sqlalchemy.exc import SQLAlchemyError

logger = logging.getLogger(__name__)

class DatabaseManager:
    _instance = None
    _engine = None
    _session_factory = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(DatabaseManager, cls).__new__(cls)
        return cls._instance
    
    def __init__(self):
        if not hasattr(self, "initialized"):
            self.initialized = True
            self._setup_connection()
    
    def _setup_connection(self):
        try:
            db_url = self._get_database_url()
            self._engine = create_engine(db_url, echo=os.getenv("DB_ECHO", "false").lower() == "true")
            self._session_factory = sessionmaker(bind=self._engine)
            logger.info("Database connection established")
        except Exception as e:
            logger.error(f"Database connection failed: {e}")
            raise
    
    def _get_database_url(self):
        host = os.getenv("DB_HOST", "postgres")
        port = os.getenv("DB_PORT", "5432")
        database = os.getenv("DB_NAME", "test_second_db")
        username = os.getenv("DB_USER", "test_second_db_user")
        password = os.getenv("DB_PASSWORD", "")
        return f"postgresql://{username}:{password}@{host}:{port}/{database}"
    
    @contextmanager
    def get_session(self):
        session = self._session_factory()
        try:
            yield session
            session.commit()
        except Exception as e:
            session.rollback()
            logger.error(f"Database session error: {e}")
            raise
        finally:
            session.close()
    
    def execute_raw_sql(self, query: str, params: Optional[Dict[str, Any]] = None, fetch_all: bool = True):
        with self.get_session() as session:
            try:
                result = session.execute(text(query), params or {})
                if query.strip().upper().startswith(("SELECT", "WITH")):
                    if fetch_all:
                        rows = result.fetchall()
                        return [dict(row._mapping) for row in rows]
                    else:
                        row = result.fetchone()
                        return dict(row._mapping) if row else None
                else:
                    return {"affected_rows": result.rowcount}
            except SQLAlchemyError as e:
                logger.error(f"SQL execution error: {e}")
                raise

def get_db_manager():
    return DatabaseManager()

def execute_sql(query: str, params: Optional[Dict[str, Any]] = None, fetch_all: bool = True):
    return get_db_manager().execute_raw_sql(query, params, fetch_all)