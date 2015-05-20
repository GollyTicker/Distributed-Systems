/*
 *  MICO --- an Open Source CORBA implementation
 *  Copyright (c) 1997-2006 by The Mico Team
 *
 *  This file was automatically generated. DO NOT EDIT!
 */

#include <CORBA.h>
#include <mico/throw.h>

#ifndef __CHEF_H__
#define __CHEF_H__






namespace chef
{

class koordinator;
typedef koordinator *koordinator_ptr;
typedef koordinator_ptr koordinatorRef;
typedef ObjVar< koordinator > koordinator_var;
typedef ObjOut< koordinator > koordinator_out;

}






namespace chef
{


/*
 * Base class and common definitions for interface koordinator
 */

class koordinator : 
  virtual public CORBA::Object
{
  public:
    virtual ~koordinator();

    #ifdef HAVE_TYPEDEF_OVERLOAD
    typedef koordinator_ptr _ptr_type;
    typedef koordinator_var _var_type;
    #endif

    static koordinator_ptr _narrow( CORBA::Object_ptr obj );
    static koordinator_ptr _narrow( CORBA::AbstractBase_ptr obj );
    static koordinator_ptr _duplicate( koordinator_ptr _obj )
    {
      CORBA::Object::_duplicate (_obj);
      return _obj;
    }

    static koordinator_ptr _nil()
    {
      return 0;
    }

    virtual void *_narrow_helper( const char *repoid );

    virtual CORBA::Long getsteeringval( CORBA::Long_out pnum, CORBA::Long_out wtime, CORBA::Long_out term ) = 0;
    virtual CORBA::Long hello( CORBA::Long pid ) = 0;
    virtual void brief( CORBA::Long pid, CORBA::Long pm, CORBA::Long ptime ) = 0;
    virtual void terminated( CORBA::Long pid, CORBA::Long ggt, CORBA::Long ptime ) = 0;
    virtual void closed( CORBA::Long pid, CORBA::Long pm, CORBA::Long ptime ) = 0;

  protected:
    koordinator() {};
  private:
    koordinator( const koordinator& );
    void operator=( const koordinator& );
};

// Stub for interface koordinator
class koordinator_stub:
  virtual public koordinator
{
  public:
    virtual ~koordinator_stub();
    CORBA::Long getsteeringval( CORBA::Long_out pnum, CORBA::Long_out wtime, CORBA::Long_out term );
    CORBA::Long hello( CORBA::Long pid );
    void brief( CORBA::Long pid, CORBA::Long pm, CORBA::Long ptime );
    void terminated( CORBA::Long pid, CORBA::Long ggt, CORBA::Long ptime );
    void closed( CORBA::Long pid, CORBA::Long pm, CORBA::Long ptime );

  private:
    void operator=( const koordinator_stub& );
};

#ifndef MICO_CONF_NO_POA

class koordinator_stub_clp :
  virtual public koordinator_stub,
  virtual public PortableServer::StubBase
{
  public:
    koordinator_stub_clp (PortableServer::POA_ptr, CORBA::Object_ptr);
    virtual ~koordinator_stub_clp ();
    CORBA::Long getsteeringval( CORBA::Long_out pnum, CORBA::Long_out wtime, CORBA::Long_out term );
    CORBA::Long hello( CORBA::Long pid );
    void brief( CORBA::Long pid, CORBA::Long pm, CORBA::Long ptime );
    void terminated( CORBA::Long pid, CORBA::Long ggt, CORBA::Long ptime );
    void closed( CORBA::Long pid, CORBA::Long pm, CORBA::Long ptime );

  protected:
    koordinator_stub_clp ();
  private:
    void operator=( const koordinator_stub_clp & );
};

#endif // MICO_CONF_NO_POA

}


#ifndef MICO_CONF_NO_POA



namespace POA_chef
{

class koordinator : virtual public PortableServer::StaticImplementation
{
  public:
    virtual ~koordinator ();
    chef::koordinator_ptr _this ();
    bool dispatch (CORBA::StaticServerRequest_ptr);
    virtual void invoke (CORBA::StaticServerRequest_ptr);
    virtual CORBA::Boolean _is_a (const char *);
    virtual CORBA::InterfaceDef_ptr _get_interface ();
    virtual CORBA::RepositoryId _primary_interface (const PortableServer::ObjectId &, PortableServer::POA_ptr);

    virtual void * _narrow_helper (const char *);
    static koordinator * _narrow (PortableServer::Servant);
    virtual CORBA::Object_ptr _make_stub (PortableServer::POA_ptr, CORBA::Object_ptr);

    virtual CORBA::Long getsteeringval( CORBA::Long_out pnum, CORBA::Long_out wtime, CORBA::Long_out term ) = 0;
    virtual CORBA::Long hello( CORBA::Long pid ) = 0;
    virtual void brief( CORBA::Long pid, CORBA::Long pm, CORBA::Long ptime ) = 0;
    virtual void terminated( CORBA::Long pid, CORBA::Long ggt, CORBA::Long ptime ) = 0;
    virtual void closed( CORBA::Long pid, CORBA::Long pm, CORBA::Long ptime ) = 0;

  protected:
    koordinator () {};

  private:
    koordinator (const koordinator &);
    void operator= (const koordinator &);
};

}


#endif // MICO_CONF_NO_POA

extern CORBA::StaticTypeInfo *_marshaller_chef_koordinator;

#endif
