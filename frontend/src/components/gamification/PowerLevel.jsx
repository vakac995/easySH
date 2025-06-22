/**
 * @file PowerLevel.jsx
 * @description This component displays the user's power level as a progress bar with a title and percentage.
 * It uses framer-motion for animations and displays different colors and titles based on the power level.
 * @requires react
 * @requires prop-types
 * @requires framer-motion
 */
import React from 'react';
import PropTypes from 'prop-types';
import { motion } from 'framer-motion';

/**
 * A component that displays the user's power level.
 * @param {object} props - The component's props.
 * @param {number} props.level - The user's power level.
 * @returns {JSX.Element} The power level component.
 */
const PowerLevel = ({ level }) => {
  /**
   * Returns a color for the power level bar based on the level.
   * @param {number} level - The user's power level.
   * @returns {string} The color for the power level bar.
   */
  const getPowerColor = (level) => {
    if (level >= 80) return 'from-yellow-400 via-orange-500 to-red-500';
    if (level >= 60) return 'from-green-400 via-emerald-500 to-blue-500';
    if (level >= 40) return 'from-blue-400 via-indigo-500 to-purple-500';
    if (level >= 20) return 'from-indigo-400 via-purple-500 to-pink-500';
    return 'from-gray-400 via-gray-500 to-gray-600';
  };

  /**
   * Returns a title for the power level based on the level.
   * @param {number} level - The user's power level.
   * @returns {string} The title for the power level.
   */
  const getPowerTitle = (level) => {
    if (level >= 90) return 'Power Master ⚡';
    if (level >= 70) return 'Advanced User 🚀';
    if (level >= 50) return 'Intermediate 💪';
    if (level >= 25) return 'Beginner 🌱';
    return 'Getting Started 🎯';
  };

  /**
   * Returns a background glow for the power level component based on the level.
   * @param {number} level - The user's power level.
   * @returns {string} The background glow for the power level component.
   */
  const getBackgroundGlow = (level) => {
    if (level >= 80) return 'shadow-yellow-500/20';
    if (level >= 60) return 'shadow-green-500/20';
    if (level >= 40) return 'shadow-blue-500/20';
    if (level >= 20) return 'shadow-purple-500/20';
    return 'shadow-gray-500/10';
  };

  return (
    <div
      className={`flex flex-col items-center space-y-4 p-6 bg-gradient-to-br from-white via-gray-50 to-blue-50 dark:from-gray-800 dark:via-gray-850 dark:to-gray-900 rounded-2xl shadow-2xl ${getBackgroundGlow(level)} border-2 border-white/50 dark:border-gray-700 backdrop-blur-sm`}
    >
      <div className='flex items-center space-x-3'>
        <motion.span
          className='text-3xl'
          animate={{ rotate: [0, 10, -10, 0] }}
          transition={{ duration: 2, repeat: Infinity, repeatDelay: 3 }}
        >
          ⚡
        </motion.span>
        <h3 className='text-xl font-bold bg-gradient-to-r from-gray-800 to-blue-600 dark:from-white dark:to-blue-300 bg-clip-text text-transparent'>
          Power Level
        </h3>
      </div>

      <div className='relative w-64 h-8 bg-gradient-to-r from-gray-200 to-gray-300 dark:from-gray-700 dark:to-gray-600 rounded-full overflow-hidden shadow-inner border border-gray-300 dark:border-gray-600'>
        <motion.div
          className={`h-full bg-gradient-to-r ${getPowerColor(level)} rounded-full shadow-xl relative`}
          initial={{ width: 0 }}
          animate={{ width: `${level}%` }}
          transition={{ duration: 1.2, ease: 'easeOut' }}
        >
          {/* Animated shine effect */}
          <motion.div
            className='absolute inset-0 bg-gradient-to-r from-transparent via-white/40 to-transparent rounded-full'
            animate={{ x: [`-100%`, `100%`] }}
            transition={{
              duration: 2.5,
              repeat: level > 0 ? Infinity : 0,
              ease: 'linear',
              repeatDelay: 1.5,
            }}
          />

          {/* Pulsing glow for high levels */}
          {level >= 70 && (
            <motion.div
              className='absolute inset-0 bg-white/20 rounded-full'
              animate={{ opacity: [0.2, 0.6, 0.2] }}
              transition={{ duration: 1.5, repeat: Infinity }}
            />
          )}
        </motion.div>

        {/* Progress markers */}
        <div className='absolute inset-0 flex items-center justify-between px-2'>
          {[25, 50, 75].map((marker) => (
            <div
              key={marker}
              className={`w-0.5 h-4 rounded-full ${
                level >= marker ? 'bg-white/60' : 'bg-gray-400/60 dark:bg-gray-500/60'
              }`}
              style={{ left: `${marker}%` }}
            />
          ))}
        </div>
      </div>

      <div className='text-center space-y-2'>
        <div className='flex items-center justify-center space-x-3'>
          <motion.span
            className='text-3xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 dark:from-blue-400 dark:to-purple-400 bg-clip-text text-transparent'
            animate={{ scale: level >= 100 ? [1, 1.1, 1] : 1 }}
            transition={{ duration: 0.5, repeat: level >= 100 ? Infinity : 0, repeatDelay: 2 }}
          >
            {level}%
          </motion.span>
          {level >= 100 && (
            <motion.span
              className='text-2xl'
              animate={{
                y: [0, -8, 0],
                rotate: [0, 10, -10, 0],
              }}
              transition={{ duration: 1, repeat: Infinity, repeatDelay: 1 }}
            >
              🏆
            </motion.span>
          )}
        </div>
        <motion.p
          className='text-base font-semibold text-gray-700 dark:text-gray-300'
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.5 }}
        >
          {getPowerTitle(level)}
        </motion.p>

        {/* Level-specific messages */}
        {level >= 100 && (
          <motion.p
            className='text-sm text-yellow-600 dark:text-yellow-400 font-medium'
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 1 }}
          >
            Maximum power achieved! 🚀
          </motion.p>
        )}
        {level >= 75 && level < 100 && (
          <motion.p
            className='text-sm text-green-600 dark:text-green-400 font-medium'
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 1 }}
          >
            Almost there! Keep going! 💪
          </motion.p>
        )}
      </div>
    </div>
  );
};

PowerLevel.propTypes = {
  level: PropTypes.number.isRequired,
};

export default PowerLevel;
