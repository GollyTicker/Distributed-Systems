package chef;


/**
* chef/koordinator_Tie.java .
* Generated by the IDL-to-Java compiler (portable), version "3.2"
* from chef.idl
* Thursday, 12 June 2008 12:48:19 o'clock CEST
*/

public class koordinator_Tie extends _koordinatorImplBase
{

  // Constructors
  public koordinator_Tie ()
  {
  }

  public koordinator_Tie (chef.koordinatorOperations impl)
  {
    super ();
    _impl = impl;
  }


  /* initial */
  public int getsteeringval (org.omg.CORBA.IntHolder pnum, org.omg.CORBA.IntHolder wtime, org.omg.CORBA.IntHolder term)
  {
    return _impl.getsteeringval(pnum, wtime, term);
  } // getsteeringval

  public int hello (int pid)
  {
    return _impl.hello(pid);
  } // hello


  /* bereit */
  public void brief (int pid, int pm, int ptime)
  {
    _impl.brief(pid, pm, ptime);
  } // brief

  public void terminated (int pid, int ggt, int ptime)
  {
    _impl.terminated(pid, ggt, ptime);
  } // terminated


  /* beenden */
  public void closed (int pid, int pm, int ptime)
  {
    _impl.closed(pid, pm, ptime);
  } // closed

  private chef.koordinatorOperations _impl;

} // class koordinator_Tie
