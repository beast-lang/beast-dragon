#ifndef NATI_TASKCONTEXT_H
#define NATI_TASKCONTEXT_H

#include <thread>
#include <nati/utility.h>

namespace nati {

	class TaskContext final {
		friend class TaskManager;

	public:
		TaskContext();
		~TaskContext();

	public:
		/**
		 * Returns a context for the current thread
		 */
		static TaskContext *current();

	private:
		/**
		 * Context function. Only te be run from TaskManager thread with locked TaskManager mutex
		 */
		void contextProcedure();

	private:
		/**
		 * A context the current context is waiting for; nullptr if none
		 */
		TaskContext *waitingFor_ = nullptr;
		std::thread thread_;
		/**
		 * Condition used for waking the thread when it is waiting for another thread
		 */
		MutexCondition condition_;

	};

}

#endif //NATI_TASKCONTEXT_H
