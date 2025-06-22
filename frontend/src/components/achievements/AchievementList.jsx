/**
 * @file AchievementList.jsx
 * @description This component displays a list of recent achievements.
 * It uses framer-motion for animations and limits the number of visible achievements to 3.
 * @requires react
 * @requires prop-types
 * @requires framer-motion
 * @requires ./Achievement
 */

import React from 'react';
import PropTypes from 'prop-types';
import { AnimatePresence } from 'framer-motion';
import Achievement from './Achievement';

/**
 * A component that displays a list of recent achievements.
 * @param {object} props - The component's props.
 * @param {Array<object>} props.achievements - The list of achievements to display.
 * @returns {JSX.Element} The achievement list component.
 */
const AchievementList = ({ achievements }) => {
  // Sort achievements by timestamp (newest first) and limit to last 3
  const recentAchievements = [...achievements]
    .sort((a, b) => (b.timestamp || 0) - (a.timestamp || 0))
    .slice(0, 3);

  return (
    <div className='fixed top-6 right-6 flex flex-col items-end space-y-3 z-[9999] w-80 pointer-events-none'>
      <AnimatePresence mode='popLayout'>
        {recentAchievements.map((achievement) => (
          <div
            key={`${achievement.id}-${achievement.timestamp}`}
            className='pointer-events-auto w-full'
          >
            <Achievement {...achievement} />
          </div>
        ))}
      </AnimatePresence>

      {achievements.length > 3 && (
        <div className='text-sm text-gray-800 dark:text-gray-200 bg-white/95 dark:bg-gray-800/95 backdrop-blur-md px-4 py-3 rounded-xl shadow-xl border border-gray-200 dark:border-gray-600 pointer-events-auto w-full text-center'>
          <span className='font-semibold text-blue-600 dark:text-blue-400'>
            +{achievements.length - 3}
          </span>{' '}
          more achievements unlocked! 🎉
        </div>
      )}
    </div>
  );
};

AchievementList.propTypes = {
  achievements: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.string.isRequired,
      title: PropTypes.string.isRequired,
      icon: PropTypes.string.isRequired,
      description: PropTypes.string,
      timestamp: PropTypes.number,
      isNew: PropTypes.bool,
    }),
  ).isRequired,
};

export default AchievementList;
