#pragma once

#include "TrajectoryStore.hpp"
#include "satDataContainer.h"

#include "Rinex3ObsStream.hpp"
#include "Rinex3ObsHeader.hpp"

#include <math.h>

namespace gnsssimulator {


class PRsolution {

public:

	typedef map<CivilTime, pair<Triple, map<SatID, Triple>>> PRSolutionContainer;

	/* Get the calculated "Pseudorange" without any additional errors applied.
		@param: Trajectory position
		@param: Satellite position
		@return: double pseudorange
	*/
	double getPRSolution_abs(gpstk::Triple&,gpstk::Triple&);

	/*	Write calculated C1 solution to a valid Rinex file
		/Uses a template input Rinex observation header, which's
		values are changed. Some fields may be invalid.
	*/
	void createRinexFile(void);

	/* Pass the complete Data Container from whoch PseudoRanges can be calculated*/
	void prepareRinexData(PRSolutionContainer&);
	void prepareRinexData(PRSolutionContainer&, string additionalComments);

	/* Get Direct Pseudorange from emission time, clock offset and observations
	*/
	double getPR_direct();

	/*Get Pseudorange with iterative method*/
	double getPR_iterative();

private:



	gpstk::Position trajPos, satPos;
	PRSolutionContainer& prsolutioncontainer;
	double pr_it_treshold;

};
}