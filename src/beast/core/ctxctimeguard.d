module beast.core.ctxctimeguard;

import beast.core.context;

/// Guard for setting context.isCtime
struct ContextCtimeGuard {

public:
	this(bool ctime) {
		ctime_ = context.isCtime;
		active_ = true;

		context.isCtime = ctime;
	}

	~this() {
		if (active_)
			context.isCtime = ctime_;
	}

private:
	bool ctime_;
	bool active_ = false;

}
