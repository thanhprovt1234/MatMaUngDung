package ute.shop.config;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;
import ute.shop.utils.FieldEncryptionUtils;

@Converter
public class EncryptedStringConverter implements AttributeConverter<String, String> {
	@Override
	public String convertToDatabaseColumn(String attribute) {
		return FieldEncryptionUtils.encrypt(attribute);
	}

	@Override
	public String convertToEntityAttribute(String dbData) {
		return FieldEncryptionUtils.decrypt(dbData);
	}
}
