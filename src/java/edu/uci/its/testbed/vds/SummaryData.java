package edu.uci.its.testbed.vds;

import org.svenson.JSON;
import org.svenson.JSONProperty;

public class SummaryData
{
    public Integer n = new Integer(0);
    public Float o = new Float(0.0);
    public Float pct = new Float( 0.0 );
    public Integer lanes = new Integer( 0);
    public Integer intrvls = new Integer(0);

    @JSONProperty("N")
    public Integer getN()
    {
        return n;
    }
    public void setN( Integer n )
    {
        this.n = n;
    }

    @JSONProperty("O")
    public Float getO()
    {
        return o;
    }
    public void setO( Float o )
    {
	this.o = o;
    }

    @JSONProperty("Pct")
    public Float getPct()
    {
        return pct;
    }
    public void setPct( Float pct )
    {
	this.pct = pct;
    }

    @JSONProperty( "lanes" )
    public Integer getLanes()
    {
	return lanes;
    }
    public void setLanes( Integer lanes )
    {
	this.lanes = lanes;
    }

    @JSONProperty( "intrvls" )
    public Integer getIntrvls()
    {
	return intrvls;
    }
    public void setIntrvls( Integer intrvls )
    {
	this.intrvls = intrvls;
    }


    public String toString()
    {
        //return [ "N:", n, "O:", o, "%:", pct, "l:", lanes, "i:", intrvls ].join( ", " )
	return "N:"+n+", F:" + (intrvls>0 ? ((3600.0 * n) / (intrvls*30.0)) : 0 ) + ", O:" +  o + ", %:" + pct + ", l:" + lanes + ", i:" + intrvls;
    }
}
