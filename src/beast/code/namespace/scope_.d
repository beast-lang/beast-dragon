module beast.code.namespace.scope_;

import beast.core.task.context;

class Scope {

public:
	this() {
		debug jobId_ = context.jobId;
	}

public:
	final DataEntity[] members() {
		return members_;
	}

public:
	final void addMember(DataEntity member) {
		debug assert(context.jobId == jobId_, "Adding membes from a different job");
		debug assert(!accessedFromDifferentJob_, "Already accessed from a different job");

		members_ ~= member;
		if (auto id = member.identifier)
			groupedMembers_.require(id, null) ~= member;
	}

	DataEntity[] resolveIdentifier(Identifier identifier, ResolutionFlags flags) {
		debug accessedFromDifferentJob_ = accessedFromDifferentJob_ || context.jobId != jobId_;

		if(auto match = identifier in groupedMembers_)
			return *match;

		return null;
	}

private:
	debug JobId jobId_;
	debug bool accessedFromDifferentJob_ = false;

	DataEntity[] members_;
	DataEntity[][Identifier] groupedMembers_;

}
