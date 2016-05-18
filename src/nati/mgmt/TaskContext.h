#ifndef NATI_TASKCONTEXT_H
#define NATI_TASKCONTEXT_H

#include <boost/context/all.hpp>

namespace nati {

	class TaskContext {

	private:
		boost::context::execution_context<void> context_;

	};

}

#endif //NATI_TASKCONTEXT_H
