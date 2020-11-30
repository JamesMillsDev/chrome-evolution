using UnityEngine;

using System.IO;
using Array = System.Array;
using System.Collections.Generic;
using Serializable = System.SerializableAttribute;

namespace ChromeEvo.API.Networking
{
	[Serializable]
	public class PacketBuffer 
	{
		public byte[] Data;
		public int FloatCount;
		public int IntCount;
		public int UIntCount;
		public int ByteCount;
		public int ShortCount;
		public int UShortCount;
		public int BoolCount;
		public int StringCount;

		private List<float> floatValues = new List<float>();
		private List<int> intValues = new List<int>();
		private List<uint> uintValues = new List<uint>();
		private List<byte> byteValues = new List<byte>();
		private List<short> shortValues = new List<short>();
		private List<ushort> ushortValues = new List<ushort>();
		private List<bool> boolValues = new List<bool>();
		private List<string> stringValues = new List<string>();

		public void Serialize()
		{
			Data = new byte[1];
			FloatCount = floatValues.Count;
			IntCount = intValues.Count;
			UIntCount = uintValues.Count;
			ByteCount = byteValues.Count;
			ShortCount = shortValues.Count;
			UShortCount = ushortValues.Count;
			BoolCount = boolValues.Count;
			StringCount = stringValues.Count;

			using(MemoryStream stream = new MemoryStream(100))
			{
				using(BinaryWriter writer = new BinaryWriter(stream))
				{
					foreach(float f in floatValues)
					{
						writer.Write(f);
					}

					foreach(int i in intValues)
					{
						writer.Write(i);
					}

					foreach(uint u in uintValues)
					{
						writer.Write(u);
					}

					foreach(byte b in byteValues)
					{
						writer.Write(b);
					}

					foreach(short s in shortValues)
					{
						writer.Write(s);
					}

					foreach(ushort u in ushortValues)
					{
						writer.Write(u);
					}

					foreach(bool b in boolValues)
					{
						writer.Write(b);
					}

					foreach(string s in stringValues)
					{
						writer.Write(s);
					}
				}

				byte[] data = stream.GetBuffer();
				Array.Resize(ref Data, data.Length);
				Array.Copy(data, Data, data.Length);
			}

			floatValues.Clear();
			intValues.Clear();
			uintValues.Clear();
			byteValues.Clear();
			shortValues.Clear();
			ushortValues.Clear();
			boolValues.Clear();
			stringValues.Clear();
		}

		public void Deserialize()
		{
			floatValues.Clear();
			intValues.Clear();
			uintValues.Clear();
			byteValues.Clear();
			shortValues.Clear();
			ushortValues.Clear();
			boolValues.Clear();
			stringValues.Clear();

			using(MemoryStream stream = new MemoryStream(Data))
			{
				using(BinaryReader reader = new BinaryReader(stream))
				{
					for(int i = 0; i < FloatCount; i++)
					{
						floatValues.Add(reader.ReadSingle());
					}

					for(int i = 0; i < IntCount; i++)
					{
						intValues.Add(reader.ReadInt32());
					}

					for(int i = 0; i < UIntCount; i++)
					{
						uintValues.Add(reader.ReadUInt32());
					}

					for(int i = 0; i < ByteCount; i++)
					{
						byteValues.Add(reader.ReadByte());
					}

					for(int i = 0; i < ShortCount; i++)
					{
						shortValues.Add(reader.ReadInt16());
					}

					for(int i = 0; i < UShortCount; i++)
					{
						ushortValues.Add(reader.ReadUInt16());
					}

					for(int i = 0; i < BoolCount; i++)
					{
						boolValues.Add(reader.ReadBoolean());
					}

					for(int i = 0; i < StringCount; i++)
					{
						stringValues.Add(reader.ReadString());
					}
				}
			}
		}

		public void WriteFloat(float _value)
		{
			floatValues.Add(_value);
		}

		public void WriteInt(int _value)
		{
			intValues.Add(_value);
		}

		public void WriteUInt(uint _value)
		{
			uintValues.Add(_value);
		}

		public void WriteByte(byte _value)
		{
			byteValues.Add(_value);
		}

		public void WriteShort(short _value)
		{
			shortValues.Add(_value);
		}

		public void WriteUShort(ushort _value)
		{
			ushortValues.Add(_value);
		}

		public void WriteBool(bool _value)
		{
			boolValues.Add(_value);
		}

		public void WriteString(string _value)
		{
			stringValues.Add(_value);
		}

		public void WriteVector3(Vector3 _value)
		{
			floatValues.Add(_value.x);
			floatValues.Add(_value.y);
			floatValues.Add(_value.z);
		}

		public void WriteQuaternion(Quaternion _value)
		{
			floatValues.Add(_value.eulerAngles.x);
			floatValues.Add(_value.eulerAngles.y);
			floatValues.Add(_value.eulerAngles.z);
		}

		public float ReadFloat()
		{
			float val = floatValues[0];
			floatValues.RemoveAt(0);
			return val;
		}

		public int ReadInt()
		{
			int val = intValues[0];
			intValues.RemoveAt(0);
			return val;
		}

		public uint ReadUInt()
		{
			uint val = uintValues[0];
			uintValues.RemoveAt(0);
			return val;
		}

		public byte ReadByte()
		{
			byte val = byteValues[0];
			byteValues.RemoveAt(0);
			return val;
		}

		public short ReadShort()
		{
			short val = shortValues[0];
			shortValues.RemoveAt(0);
			return val;
		}

		public ushort ReadUShort()
		{
			ushort val = ushortValues[0];
			ushortValues.RemoveAt(0);
			return val;
		}

		public bool ReadBool()
		{
			bool val = boolValues[0];
			boolValues.RemoveAt(0);
			return val;
		}

		public string ReadString()
		{
			string val = stringValues[0];
			stringValues.RemoveAt(0);
			return val;
		}

		public Vector3 ReadVector3()
		{
			float x = floatValues[0];
			float y = floatValues[1];
			float z = floatValues[2];
			
			floatValues.RemoveAt(0);
			floatValues.RemoveAt(0);
			floatValues.RemoveAt(0);

			return new Vector3(x, y, z);
		}

		public Quaternion ReadQuaternion()
		{
			float x = floatValues[0];
			float y = floatValues[1];
			float z = floatValues[2];
			
			floatValues.RemoveAt(0);
			floatValues.RemoveAt(0);
			floatValues.RemoveAt(0);

			return Quaternion.Euler(new Vector3(x, y, z));
		}
	}
}