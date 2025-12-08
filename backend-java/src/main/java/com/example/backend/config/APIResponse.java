package com.example.backend.config;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.FieldDefaults;

@Data
@Builder
@FieldDefaults( level = AccessLevel.PRIVATE)
@AllArgsConstructor
@NoArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class APIResponse<T> {
    @Builder.Default
    int code = 1000;
    String message;
    T result;
    public static <T> APIResponse<T> notFound(String s){
        return APIResponse.<T>builder()
                .code(404)
                .message(s)
                .result(null)
                .build();
    }
    public static <T> APIResponse<T> success(T result){
        return APIResponse.<T>builder()
                .code(1000)
                .message("Success")
                .result(result)
                .build();
    }
    public static <T> APIResponse<T> error(String message) {
        return APIResponse.<T>builder()
                .code(9999)
                .message(message)
                .build();
    }

}
