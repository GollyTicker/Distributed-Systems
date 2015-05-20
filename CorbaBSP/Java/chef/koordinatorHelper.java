package chef;


/**
* chef/koordinatorHelper.java .
* Generated by the IDL-to-Java compiler (portable), version "3.2"
* from chef.idl
* Thursday, 12 June 2008 12:48:19 o'clock CEST
*/

abstract public class koordinatorHelper
{
  private static String  _id = "IDL:chef/koordinator:1.0";

  public static void insert (org.omg.CORBA.Any a, chef.koordinator that)
  {
    org.omg.CORBA.portable.OutputStream out = a.create_output_stream ();
    a.type (type ());
    write (out, that);
    a.read_value (out.create_input_stream (), type ());
  }

  public static chef.koordinator extract (org.omg.CORBA.Any a)
  {
    return read (a.create_input_stream ());
  }

  private static org.omg.CORBA.TypeCode __typeCode = null;
  synchronized public static org.omg.CORBA.TypeCode type ()
  {
    if (__typeCode == null)
    {
      __typeCode = org.omg.CORBA.ORB.init ().create_interface_tc (chef.koordinatorHelper.id (), "koordinator");
    }
    return __typeCode;
  }

  public static String id ()
  {
    return _id;
  }

  public static chef.koordinator read (org.omg.CORBA.portable.InputStream istream)
  {
    return narrow (istream.read_Object (_koordinatorStub.class));
  }

  public static void write (org.omg.CORBA.portable.OutputStream ostream, chef.koordinator value)
  {
    ostream.write_Object ((org.omg.CORBA.Object) value);
  }

  public static chef.koordinator narrow (org.omg.CORBA.Object obj)
  {
    if (obj == null)
      return null;
    else if (obj instanceof chef.koordinator)
      return (chef.koordinator)obj;
    else if (!obj._is_a (id ()))
      throw new org.omg.CORBA.BAD_PARAM ();
    else
    {
      org.omg.CORBA.portable.Delegate delegate = ((org.omg.CORBA.portable.ObjectImpl)obj)._get_delegate ();
      chef._koordinatorStub stub = new chef._koordinatorStub ();
      stub._set_delegate(delegate);
      return stub;
    }
  }

  public static chef.koordinator unchecked_narrow (org.omg.CORBA.Object obj)
  {
    if (obj == null)
      return null;
    else if (obj instanceof chef.koordinator)
      return (chef.koordinator)obj;
    else
    {
      org.omg.CORBA.portable.Delegate delegate = ((org.omg.CORBA.portable.ObjectImpl)obj)._get_delegate ();
      chef._koordinatorStub stub = new chef._koordinatorStub ();
      stub._set_delegate(delegate);
      return stub;
    }
  }

}
