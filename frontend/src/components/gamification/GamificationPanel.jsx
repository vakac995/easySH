import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { motion, AnimatePresence } from 'framer-motion';
import PowerLevel from './PowerLevel';

const GamificationPanel = ({ level, achievements, config }) => {
  const [isExpanded, setIsExpanded] = useState(false);

  const getCompletionStats = () => {
    const stats = [];

    if (config.projectName !== 'MyNewProject') {
      stats.push({ label: 'Project Named', completed: true, points: 20 });
    } else {
      stats.push({ label: 'Project Named', completed: false, points: 20 });
    }

    stats.push({
      label: 'Database Selected',
      completed: config.backend.database !== 'postgresql' || config.backend.database === 'sqlite',
      points: config.backend.database === 'sqlite' ? 15 : 10,
    });

    stats.push({
      label: 'UI Library Selected',
      completed: config.frontend.uiLibrary !== 'none',
      points: config.frontend.uiLibrary === 'tailwindcss' ? 20 : 15,
    });

    stats.push({
      label: 'Authentication Module',
      completed: config.modules.authentication,
      points: 25,
    });

    stats.push({
      label: 'Notifications Module',
      completed: config.modules.notifications,
      points: 20,
    });

    return stats;
  };

  const completionStats = getCompletionStats();
  const completedTasks = completionStats.filter((stat) => stat.completed).length;
  const totalTasks = completionStats.length;

  return (
    <div className='bg-gradient-to-br from-white to-blue-50 dark:from-gray-800 dark:to-gray-900 rounded-xl shadow-xl border border-blue-200 dark:border-gray-700 overflow-hidden'>
      {/* Header Section */}
      <div className='bg-gradient-to-r from-blue-600 to-purple-600 text-white p-4'>
        <div className='flex items-center justify-between'>
          <div className='flex items-center space-x-3'>
            <div className='w-12 h-12 bg-white/20 rounded-full flex items-center justify-center backdrop-blur-sm'>
              <span className='text-2xl'>🎮</span>
            </div>
            <div>
              <h3 className='text-xl font-bold'>Progress Dashboard</h3>
              <p className='text-blue-100 text-sm'>Track your configuration journey</p>
            </div>
          </div>
          <button
            onClick={() => setIsExpanded(!isExpanded)}
            className='bg-white/20 hover:bg-white/30 text-white text-sm font-medium px-4 py-2 rounded-lg transition-all duration-200 backdrop-blur-sm'
          >
            {isExpanded ? 'Hide Details' : 'Show Details'}
          </button>
        </div>
      </div>

      {/* Main Content */}
      <div className='p-6'>
        {/* Stats Grid */}
        <div className='grid grid-cols-1 md:grid-cols-3 gap-6 mb-6'>
          <div className='text-center bg-gradient-to-br from-blue-50 to-blue-100 dark:from-blue-900/20 dark:to-blue-800/20 rounded-lg p-4 border border-blue-200 dark:border-blue-700'>
            <div className='text-3xl font-bold text-blue-600 dark:text-blue-400 mb-1'>
              {achievements.length}
            </div>
            <div className='text-sm font-medium text-blue-700 dark:text-blue-300'>
              Achievements Unlocked
            </div>
            <div className='flex justify-center mt-2'>
              {achievements.slice(-3).map((achievement, index) => (
                <span key={achievement.id} className='text-lg ml-1' title={achievement.title}>
                  {achievement.icon}
                </span>
              ))}
            </div>
          </div>

          <div className='text-center bg-gradient-to-br from-green-50 to-green-100 dark:from-green-900/20 dark:to-green-800/20 rounded-lg p-4 border border-green-200 dark:border-green-700'>
            <div className='text-3xl font-bold text-green-600 dark:text-green-400 mb-1'>
              {completedTasks}/{totalTasks}
            </div>
            <div className='text-sm font-medium text-green-700 dark:text-green-300'>
              Configuration Tasks
            </div>
            <div className='w-full bg-green-200 dark:bg-green-800 rounded-full h-2 mt-2'>
              <div
                className='bg-green-500 h-2 rounded-full transition-all duration-500'
                style={{ width: `${(completedTasks / totalTasks) * 100}%` }}
              />
            </div>
          </div>

          <div className='text-center bg-gradient-to-br from-purple-50 to-purple-100 dark:from-purple-900/20 dark:to-purple-800/20 rounded-lg p-4 border border-purple-200 dark:border-purple-700'>
            <div className='text-3xl font-bold text-purple-600 dark:text-purple-400 mb-1'>
              {level}%
            </div>
            <div className='text-sm font-medium text-purple-700 dark:text-purple-300'>
              Power Level
            </div>{' '}
            <div className='flex justify-center mt-2'>
              {(() => {
                if (level >= 100) return <span className='text-2xl animate-pulse'>👑</span>;
                if (level >= 75) return <span className='text-2xl'>⚡</span>;
                if (level >= 50) return <span className='text-2xl'>🔋</span>;
                return <span className='text-2xl'>🌱</span>;
              })()}
            </div>
          </div>
        </div>

        {/* Power Level Component */}
        <div className='mb-6'>
          <PowerLevel level={level} />
        </div>

        {/* Expandable Details Section */}
        <AnimatePresence>
          {isExpanded && (
            <motion.div
              initial={{ height: 0, opacity: 0 }}
              animate={{ height: 'auto', opacity: 1 }}
              exit={{ height: 0, opacity: 0 }}
              transition={{ duration: 0.3, ease: 'easeInOut' }}
              className='border-t border-gray-200 dark:border-gray-700 pt-6 overflow-hidden'
            >
              {' '}
              <div className='grid md:grid-cols-2 gap-6'>
                {/* Task Progress */}
                <div>
                  <h4 className='font-bold text-gray-800 dark:text-white mb-4 flex items-center'>
                    <span className='w-6 h-6 bg-blue-500 rounded-full flex items-center justify-center mr-2'>
                      <span className='text-white text-xs'>✓</span>
                    </span>{' '}
                    Task Progress
                  </h4>
                  <div className='space-y-3'>
                    {completionStats.map((stat) => (
                      <div
                        key={stat.label}
                        className='flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-800 rounded-lg'
                      >
                        <div className='flex items-center space-x-3'>
                          <div
                            className={`w-5 h-5 rounded-full flex items-center justify-center ${
                              stat.completed
                                ? 'bg-green-500 text-white'
                                : 'bg-gray-300 dark:bg-gray-600 text-gray-500'
                            }`}
                          >
                            {stat.completed && <span className='text-xs'>✓</span>}
                          </div>
                          <span
                            className={`text-sm font-medium ${
                              stat.completed
                                ? 'text-green-700 dark:text-green-400'
                                : 'text-gray-600 dark:text-gray-400'
                            }`}
                          >
                            {stat.label}
                          </span>
                        </div>
                        <span className='text-sm font-bold text-blue-600 dark:text-blue-400'>
                          +{stat.points}pts
                        </span>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Recent Achievements */}
                {achievements.length > 0 && (
                  <div>
                    {' '}
                    <h4 className='font-bold text-gray-800 dark:text-white mb-4 flex items-center'>
                      <span className='w-6 h-6 bg-yellow-500 rounded-full flex items-center justify-center mr-2'>
                        <span className='text-white text-xs'>🏆</span>
                      </span>{' '}
                      Recent Achievements
                    </h4>
                    <div className='space-y-3'>
                      {achievements
                        .slice(-5)
                        .reverse()
                        .map((achievement) => (
                          <div
                            key={`${achievement.id}-${achievement.timestamp}`}
                            className='flex items-center space-x-3 p-3 bg-gradient-to-r from-yellow-50 to-orange-50 dark:from-yellow-900/20 dark:to-orange-900/20 rounded-lg border border-yellow-200 dark:border-yellow-700'
                          >
                            <span className='text-2xl'>{achievement.icon}</span>
                            <div className='flex-1'>
                              <div className='font-semibold text-gray-800 dark:text-white text-sm'>
                                {achievement.title}
                              </div>
                              {achievement.description && (
                                <div className='text-xs text-gray-600 dark:text-gray-400 mt-1'>
                                  {achievement.description}
                                </div>
                              )}
                            </div>
                          </div>
                        ))}
                    </div>
                  </div>
                )}
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </div>
  );
};

GamificationPanel.propTypes = {
  level: PropTypes.number.isRequired,
  achievements: PropTypes.array.isRequired,
  config: PropTypes.object.isRequired,
};

export default GamificationPanel;
