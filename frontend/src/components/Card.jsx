import React from 'react';
import PropTypes from 'prop-types';

const Card = ({ children, className = '' }) => {
  return (
    <div
      className={`bg-white dark:bg-gray-800 shadow-md rounded-lg p-6 w-full max-w-full box-border ${className}`}
    >
      {children}
    </div>
  );
};

Card.propTypes = {
  children: PropTypes.node.isRequired,
  className: PropTypes.string,
};

export default Card;
